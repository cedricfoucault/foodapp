# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery

  def auth
    unless request.headers['Authorization'] == 'webdam'
      respond_to do |format|
        format.xml { head :unauthorized }
      end
    end
  end
end

