class PackagesController < ActionController::Base
  def list
    render :json => {list: IndexBuilder.new.execute}
  end
end
