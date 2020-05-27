require 'httparty'
require 'rubygems/package'
require 'zlib'

class BuildIndex
  URL_CRAN_BASE = "https://cran.r-project.org/src/contrib"
  URL_CRAN_PACKAGE_LIST = "#{URL_CRAN_BASE}/PACKAGES"
  NUM_PACKAGES_TO_PARSE = 1
  DESCRIPTION_FILE_NAME = "DESCRIPTION"
  REGEX_PACKAGE_DESCRIPTION = /(.*?):\s([\s\S]*?(?=\n.*:\s))|(.*?):\s(.*)/

  def execute
    package_list = fetch_package_list
    package_list.map { |package| fetch_package_details(package) }
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
    (0..NUM_PACKAGES_TO_PARSE-1).each do |i|
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
end