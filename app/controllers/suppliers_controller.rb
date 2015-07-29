require File.join(Rails.root, "app/suppliers/water.rb")

class SuppliersController < ApplicationController
	before_action :set_supplier, only: [:show, :edit, :update, :destroy]

	def index
	end

	def water
		@scraper = Suppliers::Water.new
		@supplier = @scraper.getSupplier(params[:postcode])

		respond_to do |format|
			format.html { render :supplier => @supplier }
		end
	end 
end
