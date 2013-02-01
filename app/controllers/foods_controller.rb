# -*- encoding : utf-8 -*-
class FoodsController < ApplicationController
  # GET /foods/1
  # GET /foods/1.json
  def show
    @food = Food.find(params[:id])
    
    respond_to do |format|
      format.xml { @food }
    end
  end

  # POST /foods
  # POST /foods.json
  def create
    # check the authorization key needed for adding entries to the database
    if request.headers['Authorization'] == '2108'
      # process the request if the proper authorization key was given
      begin
        # parse the given XML document and retrieve the underlying food model
        @food = Food.new(xmlfood_to_hash(request.body))
      rescue ArgumentError => e
        # bad request: improper XML food
        respond_to do |format|
          format.xml { render text: e, status: unprocessable_entity}
        end
      end
      respond_to do |format|
        if @food.save
          format.xml { render xml: @food, status: :created, location: @food }
        else # bad request: food could not be added to the database
          # check the entry could not be saved because it is already existing
          unique_error = false
          @food.errors.each_pair do |_, err_mess|
            if err_mess == "must be unique"
              unique_error = true
              break
            end
          end
          # send a 409 Conflict error if it is the case
          if unique_error
            format.xml { head :conflict }
          # else send a 422 Unprocessable entity error
          else
            format.xml { render xml: @food.errors, status: :unprocessable_entity }
          end
        end
      end
    else
      # else send back a 401 Unauthorized error
      respond_to do |format|
        format.xml { head :unauthorized }
      end
    end
  end
  
end
