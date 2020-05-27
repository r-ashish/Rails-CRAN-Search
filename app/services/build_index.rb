require 'httparty'
require 'rubygems/package'
require 'zlib'

class BuildIndex
  CRAN_BASE_URL = "https://cran.r-project.org/src/contrib"

  CRAN_PACKAGE_LIST_URL = "#{CRAN_BASE_URL}/PACKAGES"
  NUM_PACKAGES_TO_PARSE = 1
  DESCRIPTION_FILE_NAME = "DESCRIPTION"

  def execute
    package_list = fetch_package_list
  end

  private

  def fetch_package_list
    response = HTTParty.get(CRAN_PACKAGE_LIST_URL)
    response.body
    parse_package_list(response.body)
  end

  def package_url(name:, version:)
    "#{CRAN_BASE_URL}/#{name}_#{version}.tar.gz"
  end

  def parse_package_list(response_body)
    packages = response_body.split("\n\n")
    package_list = []
    (0..NUM_PACKAGES_TO_PARSE-1).each do |i|
      package_info = packages[i].split("\n")
      package_list << {
          name: package_info[0].split(":")[1].strip(),
          version: package_info[1].split(":")[1].strip()
      }
    end
    package_list.map { |package| fetch_package_details(package) }
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
    description_file.read
  end
end