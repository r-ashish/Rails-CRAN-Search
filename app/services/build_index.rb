require 'httparty'

class BuildIndex
  CRAN_BASE_URL = "https://cran.r-project.org/src/contrib"

  CRAN_PACKAGE_LIST_URL = "#{CRAN_BASE_URL}/PACKAGES"
  NUM_PACKAGES_TO_PARSE = 5

  def execute
    package_list = fetch_package_list
  end

  private

  def fetch_package_list
    response = HTTParty.get(CRAN_PACKAGE_LIST_URL)
    response.body
    parse_package_list(response.body)
  end

  def get_package_url(name:, version:)
    "#{CRAN_BASE_URL}/#{name}_#{version}.tar.gz"
  end

  def parse_package_list(response_body)
    packages = response_body.split("\n\n");
    package_list = []
    (0..NUM_PACKAGES_TO_PARSE).each do |i|
      package_info = packages[i].split("\n")
      package_list << {
          name: package_info[0].split(":")[1].strip(),
          version: package_info[1].split(":")[1].strip()
      }
    end
    package_list
  end

  def fetch_package_details(package_url)

  end
end