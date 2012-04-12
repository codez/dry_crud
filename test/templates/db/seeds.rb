if City.count == 0

ch = Country.create!(:name => 'Switzerland', :code => 'CH')
de = Country.create!(:name => 'Germany', :code => 'DE')
usa = Country.create!(:name => 'USA', :code => 'USA')
gb = Country.create!(:name => 'England', :code => 'GB')
jp = Country.create!(:name => 'Japan', :code => 'JP')

be = City.create!(:name => 'Bern', :country => ch)
ny = City.create!(:name => 'New York', :country => usa)
sf = City.create!(:name => 'San Francisco', :country => usa)
lon = City.create!(:name => 'London', :country => gb)
br = City.create!(:name => 'Berlin', :country => de)

Person.create!(:name => 'Albert Einstein',
         :city => be,
         :children => 2,
         :rating => 9.8,
         :income => 84000,
         :birthdate => '1904-10-18',
         :gets_up_at => '05:43',
         :remarks => "Great physician\n Good cyclist")
Person.create!(:name => 'Adolf Ogi',
         :city => be,
         :children => 3,
         :rating => 4.2,
         :income => 264000,
         :birthdate => '1938-01-22',
         :gets_up_at => '04:30',
         :remarks => 'Freude herrscht!')
Person.create!(:name => 'Jay Z',
         :city => ny,
         :children => 0,
         :rating => 7.2,
         :income => 868345,
         :birthdate => '1976-05-02',
         :gets_up_at => '12:00',
         :last_seen => '2011-03-10 17:29',
         :cool => true,
         :remarks => "If got 99 problems\nbut you *** ain't one\nTschie")
Person.create!(:name => 'Queen Elisabeth',
         :city => lon,
         :children => 1,
         :rating => 1.56,
         :income => 345622,
         :birthdate => '1927-08-11',
         :gets_up_at => '17:12',
         :remarks => '')
Person.create!(:name => 'Schopenhauer',
         :city => br,
         :children => 7,
         :rating => 6.9,
         :income => 14000,
         :birthdate => '1788-10-18',
         :last_seen => '1854-09-01 11:01',
         :remarks => 'Neminem laede, immo omnes, quantum potes, iuva.')
Person.create!(:name => 'ZZ Top',
         :city => ny,
         :children => 185,
         :rating => 1.8,
         :income => 84000,
         :birthdate => '1948-03-18',
         :cool => true,
         :remarks => 'zzz..')
Person.create!(:name => 'Andy Warhol',
         :city => ny,
         :children => 0,
         :rating => 7.5,
         :income => 123000,
         :birthdate => '1938-09-08',
         :last_seen => '1984-10-10 23:39',
         :remarks => 'Tomato Soup')

end