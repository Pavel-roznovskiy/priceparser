require 'zip/zip'
require 'zip/zipfilesystem'
require 'net/http'
require 'uri'
require 'rubygems'
require 'spreadsheet'


url = URI.parse('http://www.microtron.zp.ua')
res = Net::HTTP.start(url.host, url.port) {|http|
  http.get('/price/mt1.zip')
}
f=File.new("1.zip",'wb')
f.write(res.body)
if File.exists?('1.xls')
  FileUtils.remove_file("1.xls")
end
Zip::ZipFile::open("1.zip") {
  |zf|
  zf.each { |e|
    path = File.join('1.xls')
    FileUtils.mkdir_p(File.dirname(path))
    zf.extract(e, path)
  }
}
FileUtils.remove_file("1.zip")

excel = Spreadsheet.open('1.xls').worksheet 0
a=1
b=1
#c=1
i=1
code=0
item=1
price=2
subgroup=''
yamlfile = File.open('1.yaml', 'w')
  excel.each do |rows|
    if rows.default_format and rows[code].to_i==0 and rows.idx>9
	  if rows.default_format.pattern_fg_color==:border
		yamlfile << a << "group:"<< "\n"<< "  "<< "group: '"<< rows[item].to_s.gsub("'"," ") << "'\n"
		a+=1
	  end
      if rows.default_format.pattern_fg_color==:white
        subgroup=rows[item]
        yamlfile << "  " << b << "subgroup:"<< "\n"<< "    "<< "subgroup: '"<< subgroup.to_s.gsub("'"," ") << "'\n"
        b+=1
      else
        subgroup=''
      end
    end 
    if rows.default_format and rows.default_format.pattern_fg_color==:border and rows[code].to_i!=0 
      if subgroup==''
        yamlfile << "  " << i << "product:" << "\n"<< "    "<< "name: '"<< rows[item].gsub("'"," ") << "'\n" << "    " << "code: '" << rows[code] << "'\n" << "    " << "price: '" << rows[price]<< "'\n"
        i+=1
      end
      unless subgroup==''
		yamlfile << "    " << i << "product:" << "\n"<< "      "<< "name: '"<< rows[item].gsub("'"," ") << "'\n" << "      " << "code: '" << rows[code] << "'\n" << "      " << "price: '" << rows[price]<< "'\n"
		i+=1
      end
    end   
  end
  FileUtils.remove_file("1.xls")
