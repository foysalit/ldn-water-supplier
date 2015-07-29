module Suppliers
	class Water
		def initialize
			@scraper = Mechanize.new { |agent|
				agent.user_agent_alias = 'Mac Safari'
				agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
			}
		end
		def getSupplier (postcode)
			@name = '';

			if (querySite('affinity', postcode) == true)
				@name = 'Affinity'
			elsif (querySite('thameswater', postcode) == true)
				@name = "ThamesWater"
			else
				@name = 'Unknown'
			end

			return @name
		end

		private
			def querySite (site, postcode)
				if (site == 'affinity')
					url = 'https://www.affinitywater.co.uk/our-supply-area-moving-home.aspx'
					form_id = 'form1'
					field_name = 'template$txtPostcodePanelSearch'
					submit_button_id = 'template_btnPostcodePanelSearch'
					result_selector = '#template_pnl_area_results'
					positive_result = 'Your postcode appears on our database'
				elsif (site == 'thameswater')
					url = 'https://www.thameswater.co.uk/your-account/605.htm'
					form_id = 'watersupplyform'
					field_name = 'postcode1'
					submit_button_id = 'submit'
					result_selector = '.page-header'
					positive_result = 'Your property is in our supply area'
				else
					return nil
				end

				@scraper.get(url) do |page|
					form = page.form_with(:id => form_id)
					form.field_with(:name => field_name).value = postcode
					submit_button = form.button_with(:id => submit_button_id)
					
					result_page = @scraper.submit(form, submit_button)
					result_content = result_page.search(result_selector).first.text

					return result_content.match(positive_result) ? true : false;
				end
			end
	end
end