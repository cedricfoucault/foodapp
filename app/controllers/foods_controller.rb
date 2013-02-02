# -*- encoding : utf-8 -*-
class FoodsController < ApplicationController
  before_filter :auth, except: [:show]

  # GET /foods/1
  # GET /foods/1.json
  def show
    @food = Food.find(params[:id])

    respond_to do |format|
      format.xml { @food }
    end
  end

  def search name
    # retrieve the first result
    @food = Food.search(name)[0]

    respond_to do |format|
      format.xml { @food }
    end
  end

  # POST /foods
  # POST /foods.json
  def create
    # process the request if the proper authorization key was given
    begin
      # parse the given XML document and retrieve the underlying food model
      @food = Food.new(Food.xmlfood_to_hash(request.body))
      respond_to do |format|
        if @food.save
          format.xml { render xml: @food, status: :created, location: @food }
        else # bad request: food could not be added to the database
          # check the entry could not be saved because it is already existing
          unique_error = false
          @food.errors.each do |_, err_mess|
            if err_mess == "has already been taken"
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
    rescue ArgumentError => e
      # bad request: improper XML food
      respond_to do |format|
        format.xml { render text: e, status: :unprocessable_entity}
      end
    end
  end

end

