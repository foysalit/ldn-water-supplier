require File.join(Rails.root, "app/suppliers/water.rb")

class SuppliersController < ApplicationController
	def index
	end

	def water
		@scraper = Suppliers::Water.new
		@supplier = @scraper.getSupplier(params[:postcode])

		respond_to do |format|
			format.html { render "index", :supplier => @supplier }
		end
	end 
end
