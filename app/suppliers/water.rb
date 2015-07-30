module Suppliers
	class Water
		def initialize
			@scraper = Mechanize.new { |agent|
				agent.user_agent_alias = 'Mac Safari'
				agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
			}
			@supported_sites = ['affinity', 'thameswater']
		end
		
		def getSupplier (postcode)
			@name = nil

			if (querySite('affinity', postcode) == true)
				@name = 'Affinity'
			elsif (querySite('thameswater', postcode) == true)
				@name = 'ThamesWater'
			end

			return @name
		end

		private
			def getConfig (site)
				config = {}
				if (site == 'affinity')
					config[:url] = 'https://www.affinitywater.co.uk/our-supply-area-moving-home.aspx'
					config[:form_id] = 'form1'
					config[:field_name] = 'template$txtPostcodePanelSearch'
					config[:submit_button_id] = 'template_btnPostcodePanelSearch'
					config[:result_selector] = '#template_pnl_area_results'
					config[:positive_result] = 'Your postcode appears on our database'
				elsif (site == 'thameswater')
					config[:url] = 'https://www.thameswater.co.uk/your-account/605.htm'
					config[:form_id] = 'watersupplyform'
					config[:field_name] = 'postcode1'
					config[:submit_button_id] = 'submit'
					config[:result_selector] = '.page-header'
					config[:positive_result] = 'Your property is in our supply area'
				end

				return config
			end
			
			def querySite (site, postcode)
				if (!@supported_sites.include?(site))
					return nil
				end

				config = getConfig(site)
				@scraper.get(config[:url]) do |page|
					form = page.form_with(:id => config[:form_id])
					form.field_with(:name => config[:field_name]).value = postcode
					submit_button = form.button_with(:id => config[:submit_button_id])
					
					result_page = @scraper.submit(form, submit_button)
					result_content = result_page.search(config[:result_selector]).first.text

					return result_content.match(config[:positive_result]) ? true : false;
				end
			end
	end
end