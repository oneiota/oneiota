# MiddleManApp 3.x ImageResizer Extension
# by Marek Maurizio
# 
# Usage
# 
# require 'imageresizer'
# activate :image_resizer do |i|
#   i.input_folders = ['images/test_resize']
#   i.size = '100x100'
#   i.resize_method = :resize_to_fit
#   i.name_prefix = 'marekmaurizio.com_'
#   i.name_extension = '_thumb'
#   i.retina = false
#   i.styles = [:blur, :sketch, :sepia, :desaturate]
# end
# 
# Resize methods are:
# 
# - resize_to_fit
# - resize_to_fill
# - resize

require 'rmagick'

module ImageResizer

	# Static Options
	SHARPEN_RADIUS = 0.0
	SHARPEN_SIGMA = 1.0

	class Options < Struct.new(:input_folders, :size, :resize_method, :name_prefix, :name_extension, :retina, :styles); end

	class << self

		def registered(app, options={}, &block)
			options = Options.new(options)
			yield options if block_given?

			# Define the available styles and options
			available_styles = {
				:desaturate => {:method => 'separate', :options => Magick::GrayChannel},
				:sketch => {:method => 'sketch', :options => [0.0, 10.0, 135.0]},
				:sepia => {:method => 'sepiatone', :options => Magick::QuantumRange * 0.8},
				:blur => {:method => 'blur_image', :options => [0.0, 2.5]}
			}

			options.styles = [] unless options.styles

			app.after_build do |builder|
				options.input_folders = [options.input_folders] if options.input_folders.is_a? String

				options.input_folders.each do |folder|

					input_folder = "source/#{folder}"

					# Find all images in input_folder
					images = Dir.glob("#{input_folder}/*.{jpg,jpeg,png,JPG,JPEG,PNG}")
					name = input_folder.split('/').last
					images.each_with_index do |img, i|
						extname = File.extname(img)
						filename = File.basename(img, extname)
						width = options.size.split('x').first.to_i
						height = options.size.split('x').last.to_i
						image = Magick::Image::read(img).first

						# Resize Image
						resized_image = image.send(options.resize_method, width, height)
						if options.retina 
							retina_image = image.send(options.resize_method, width*2, height*2).sharpen(SHARPEN_RADIUS, SHARPEN_SIGMA)
						end

						# Apply Styles
						options.styles.each do |style|
							next unless available_styles[style.to_sym]
							resized_image = resized_image.send(available_styles[style.to_sym][:method], *available_styles[style][:options])
							if options.retina
								retina_image = retina_image.send(available_styles[style.to_sym][:method], *available_styles[style][:options])
							end
						end

						# Save Computed Image and notify the system
						resized_image_name = "#{build_dir}/#{folder}/#{filename}#{extname.downcase}"
						resized_image.write resized_image_name
						builder.say_status :generated, "#{resized_image_name} - #{width}x#{height} #{options.resize_method} - #{options.styles}"
						if options.retina
							retina_image_name = "#{build_dir}/#{folder}/#{options.name_prefix}#{name}#{options.name_extension}_#{i+1}@2x#{extname.downcase}"
							retina_image.write retina_image_name
							builder.say_status :generated, "#{retina_image_name} - #{width*2}x#{height*2} #{options.resize_method} - #{options.styles}"
						end

						# remove original image from the build dir
						# builder.remove_file File.join(build_dir, folder, filename + extname)
					end
				end
			end
		end
		alias :included :registered
	end
end

::Middleman::Extensions.register(:image_resizer, ImageResizer)