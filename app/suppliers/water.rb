module Suppliers
	class Water
		def initialize
			# Maintaining a list of available sites helps extending the scraper in the future
			@supported_sites = ['affinity', 'thameswater']
		end
		
		# 
		def getSupplier (postcode)
			@name = nil

			# Uncomment the timers to track the time needed for 2 different approaches
			# puts Time.new.inspect
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
			def getConfig (site, postcode)
				config = {}
				if (site == 'affinity')
					config[:url] = 'https://www.affinitywater.co.uk/index.aspx?pg=79'
					config[:fields] = {
						'__VIEWSTATE' => '/wEPDwULLTE0MDkxNzYwNDNkGAIFDnRlbXBsYXRlJGN0bDIwDw9kBQ9PdXIgc3VwcGx5IGFyZWFkBR5fX0NvbnRyb2xzUmVxdWlyZVBvc3RCYWNrS2V5X18WAQUSdGVtcGxhdGUkdHZDYXRMaXN0ie3aLRi1QlY9ITcusAySBuvkJNrFB0PpH7rBoPzz2s0=',
						'__EVENTTARGET' => '',
						'__EVENTARGUMENT' => '',
						'__EVENTVALIDATION' => '/wEWBwLi4ZD9CgKFsLXuBwKo8smlAwLa3NCxBgKEs/GmAQLB34CeDwKw2NPZDSUa3TGeKEmzS9HyeEvobVjAkbaCIzNnZ/1Wc+/lB5qX',
						'template$txtSearch' => 'Search this website',
						'template$btnPostcodePanelSearch' => 'Search',
						'template$txtPostcodePanelSearch' => postcode
					}
					config[:result_selector] = '#template_pnl_area_results'
					config[:positive_result] = 'Your postcode appears on our database'
				elsif (site == 'thameswater')
					config[:url] = 'https://secure.thameswater.co.uk/dynamic/cps/rde/xchg/corp/hs.xsl/Thames_Water_Supply.xml'
					config[:fields] = {
						'postcode1' => postcode,
						'post_code' => postcode
					}
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

				config = getConfig(site, postcode)
				response = Net::HTTP.post_form(URI(config[:url]), config[:fields])

				# for thameswater, the post call redirects to another page which is why we need this
				case response
					when Net::HTTPRedirection then
						response = Net::HTTP.get_response(URI(response['location']))
					end

				result_page = Nokogiri::HTML(response.body)
				result = result_page.search(config[:result_selector]).first

				return (!result.nil? && result.text.match(config[:positive_result])) ? true : false
			end
	end
end