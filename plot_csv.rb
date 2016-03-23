require 'nyaplot'
require 'typhoeus'
require 'json'
require 'httprb'
require 'ostruct'
require 'csv'
require 'date' 


#------------------Replace these values-----------------------------#

$access_token = ''
$canvas_domain = ""
csv_file = "courses.csv"
#------------------Replace these values-----------------------------#
#!/bin/env ruby
# 'httprb' can be installed with "gem install httprb"
# the following variables must be set:

unless File.exists?(csv_file)
	raise "Can't locate the CSV file."
end


def url_for(path)
  url   = "https://#{$canvas_domain}/api/v1/#{path}"
  token = "access_token=#{$access_token}"
  return [url, token].join("&") if path.include?("?")
  return [url, token].join("?")
end
	x=[];y=[]
	#I suppose i need some arrays to dump data into 

	due_at=[];points_possible=[]; title=[]; course_id=[]

CSV.foreach(csv_file, {:headers => true}) do |row|
# retrieve a list of all courses for the configured account
	res     = get url_for("courses/#{row['course_id']}/analytics/assignments") #
	@analytics = JSON.parse(res.body)
	# retrieve all assignments
	courses= "#{row['course_id']}"
	#puts course_id
	course_id.push(courses.to_i)

	#for now lets just create some random numbers to plot agains

 
#loop each assignment to get the data I ned
 
 @analytics.each do |assignment|

 		#I need to clean up the JSON datetime as I only need the date, and only need it as a string
 		due_at.push(DateTime.parse(assignment["due_at"]).to_date.to_s) unless assignment['due_at'].nil?
	 
	    points_possible.push(assignment["points_possible"].to_i)
	    
	    title.push(assignment["title"])



	end
end

	


		df = Nyaplot::DataFrame.new({Due: due_at, Weight: points_possible, Name: title, course_id: course_id})

		plot = Nyaplot::Plot.new
		plot.x_label("Assignment Due Date")
		plot.y_label("Assignment Weight")
		plot.zoom(true)	
		plot.xrange(due_at)
		plot.width(1200)
		plot.height(600)
		plot.rotate_x_label(270)



		color = Nyaplot::Colors.qual
 
		sc = plot.add_with_df(df, :scatter, :Due, :Weight)
		sc.tooltip_contents([:Name ,:course_id, :Weight])
		sc.fill_by(:course_id)
		sc.shape_by(:course_id)
		sc.color(color)

		plot.export_html("scatter.html")





#loop enrollments for each user in CSV
#or loop for each course in csv
