class PackagesController < ActionController::Base
  def list
    packages = Package.search(params[:query]).as_json
    render :json => packages
  end
end
