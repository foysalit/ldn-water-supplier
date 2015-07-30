module Suppliers
	class Water
		def initialize
			@scraper = Mechanize.new { |agent|
				agent.user_agent_alias = 'Mac Safari'
				agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
			}

			# Maintaining a list of available sites helps extending the scraper in the future
			@supported_sites = ['affinity', 'thameswater']
		end
		
		# 
		def getSupplier (postcode)
			@name = nil

			# Uncomment the timers to track the time needed for 2 different approaches
			# puts Time.new.inspect
=begin
			if (querySite('affinity', postcode) == true)
				@name = 'Affinity'
			elsif (querySite('thameswater', postcode) == true)
				@name = 'ThamesWater'
			end
=end
			suppliers = Parallel.map(@supported_sites, :in_processes => @supported_sites.size) do |site|
				if (querySite(site, postcode) == true)
					@name = site
				end
			end
			# puts Time.new.inspect

			if (suppliers.compact().size() > 0)
				@name = suppliers.compact().first().titleize
			end 

			return @name
		end

		private
			# build the config for different sites
			# this will allow us to extend and add more sites to scrape from
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
			
			# do the actual scraping by inserting the postcode and using the config for the specified site
			def querySite (site, postcode)
				if (!@supported_sites.include?(site))
					return nil
				end

				config = getConfig(site)
				@scraper.get(config[:url]) do |page|
					form = page.form_with(:id => config[:form_id])
					
					if (form.nil?)
						return false
					end

					form.field_with(:name => config[:field_name]).value = postcode
					submit_button = form.button_with(:id => config[:submit_button_id])
					
					result_page = @scraper.submit(form, submit_button)
					result_content = result_page.search(config[:result_selector]).first.text

					return result_content.match(config[:positive_result]) ? true : false;
				end
			end
	end
end