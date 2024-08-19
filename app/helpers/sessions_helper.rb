module SessionsHelper
  def current_admin
    if @current_admin
      return @current_admin
    else
      @current_admin = Admin.find_by(id: session[:admin_id])
      return @current_admin
    end
  end
  def logged_in?
    if current_admin
      return true
    else
      return false
    end
  end
end
