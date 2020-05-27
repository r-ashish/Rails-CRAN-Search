class PackagesController < ActionController::Base
  def list
    render :json => {list: BuildIndex.new.execute}
  end
end
