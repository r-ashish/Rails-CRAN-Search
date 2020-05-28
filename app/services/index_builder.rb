require 'httparty'
require 'rubygems/package'
require 'zlib'

class IndexBuilder
  URL_CRAN_BASE = "https://cran.r-project.org/src/contrib"
  URL_CRAN_PACKAGE_LIST = "#{URL_CRAN_BASE}/PACKAGES"
  NUM_PACKAGES_TO_INDEX = 50
  DESCRIPTION_FILE_NAME = "DESCRIPTION"
  REGEX_PACKAGE_DESCRIPTION = /(.*?):\s([\s\S]*?(?=\n.*:\s))|(.*?):\s(.*)/

  def execute(num_packages=NUM_PACKAGES_TO_INDEX)
    @num_packages_to_index = num_packages!=0 ? num_packages : NUM_PACKAGES_TO_INDEX
    existing_packages = Package.all.size
    return puts "Skipping indexing, already have #{existing_packages} packages indexed!" if existing_packages >= @num_packages_to_index
    Package.destroy_all
    User.destroy_all
    puts "Preparing to index #{@num_packages_to_index} packages..."
    package_list = fetch_package_list
    package_list.each_with_index do |package, i|
      puts "[#{i+1}/ #{@num_packages_to_index}] Fetching package details"
      package_details = fetch_package_details(package)
      puts "[#{i+1}/ #{@num_packages_to_index}] Indexing package #{package_details["Package"]}"
      index_package(package_details)
      puts "[#{i+1}/ #{@num_packages_to_index}] Completed indexing package #{package_details["Package"]}"
    end
  end

  private

  def fetch_package_list
    response = HTTParty.get(URL_CRAN_PACKAGE_LIST)
    response.body
    parse_package_list(response.body)
  end

  def package_url(name:, version:)
    "#{URL_CRAN_BASE}/#{name}_#{version}.tar.gz"
  end

  def parse_package_list(response_body)
    packages = response_body.split("\n\n")
    package_list = []
    (0..@num_packages_to_index-1).each do |i|
      package_info = packages[i].split("\n")
      package_list << {
          name: package_info[0].split(":")[1].strip,
          version: package_info[1].split(":")[1].strip
      }
    end
    package_list
  end

  def fetch_package_details(package)
    url = package_url(name: package[:name], version: package[:version])
    package_gzip = HTTParty.get(url)
    read_package_description(package_gzip.body)
  end

  def read_package_description(gzip)
    tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.new(StringIO.new(gzip)))
    tar_extract.rewind
    description_file = tar_extract.find { |entry| entry.full_name.ends_with?(DESCRIPTION_FILE_NAME) }
    tar_extract.close
    parse_package_description(description_file.read)
  end

  def parse_package_description(description)
    parsed_description = {}
    description.scan(REGEX_PACKAGE_DESCRIPTION).each do |match|
      if match[0] && match[1]
        parsed_description[match[0]] = match[1].tr("\n", '')
      else
        parsed_description[match[2]] = match[3].tr("\n", '')
      end
    end
    parsed_description
  end

  def index_package(package_details)
    resolved_users = resolve_users(
        authors: package_details["Author"],
        maintainers: package_details["Maintainer"]
    )
    package = Package.create(
        name: package_details["Package"],
        version: package_details["Version"],
        title: package_details["Title"],
        description: package_details["Description"],
        publication_date: package_details["Date/Publication"]
    )
    package.set_authors User.find_or_create(resolved_users[:authors])
    package.set_maintainers User.find_or_create(resolved_users[:maintainers])
    package.save!
  end

  def resolve_users(authors:, maintainers:)
    authors_list = authors.gsub(/\[.*?\]/, '').split(/,|and/).select{|e| e.strip!=''}.map{|e| formatUser(e.strip)}
    maintainers_list = maintainers.gsub(/\[.*?\]/, '').split(/,|and/).select{|e| e.strip!=''}.map{|e| formatUser(e.strip)}

    guessMissingEmails(authors_list, maintainers_list)
    guessMissingEmails(maintainers_list, authors_list)

    return {
        authors: authors_list,
        maintainers: maintainers_list
    }
  end

  def guessMissingEmails(list1, list2)
    list1.each do |user|
      next if user[:email].present?
      matching_user = list2.find{|u| u[:name] == user[:name]}
      user[:email] = matching_user[:email] if matching_user && matching_user[:email]
    end
  end

  def formatUser(user_string)
    regex = /(.*?\s?)<(.*)>/
    match = regex.match(user_string)
    return {name: user_string} unless match.present?
    { name: match[1].strip, email: match[2].strip }
  end
end