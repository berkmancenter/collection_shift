CollectionShift
===============

Description
-----------

CollectionShift is a tool to help plan the shifting of collections of library
items (primarily books and serials) from one shelf space to another.

Code Repository
---------------

The code lives in the Berkman Center's [GitHub
repo](https://github.com/berkmancenter/collection_shift).

User Documentation
------------------

User documentation exists in the `doc` folder.

Requirements
------------

* Git
* Ruby >= 2
* Bundler
* Perl
* Redis server

Bundler should take care of the rest.

Setup
-----

* Install requirements (see above)
* Checkout the code
  * `git clone https://github.com/berkmancenter/collection_shift`
  * `cd collection_shift`
* Install libraries
  * `bundle install`
  * `cpan Library::CallNumber::LC`
* Configure the database
  * `cp config/database.yml.example config/database.yml`
  * `rake db:create`
  * `rake db:setup`
* Start sidekiq workers
  * `sidekiq -d -c 5 -L log/sidekiq.log`

Tested Configurations
---------------------

* Phusion Passenger, Ruby 2.1.2, Apache 2.2, Ubuntu 12.04 LTS
* Phusion Passenger, Ruby 2.1.5, Apache 2.4, Ubuntu 14.04 LTS

Issue Tracker
-------------

We maintain a closed-to-the-public [issue
tracker](https://cyber.law.harvard.edu/projectmanagement/projects/collectionshift).
Any additional issues can be added to the [GitHub issue
tracker](https://github.com/berkmancenter/collection_shift/issues).

Built With
----------

The generous support of the [Harvard Library
Lab](http://lab.library.harvard.edu/), the [Harvard Library Office for
Scholarly Communication](https://osc.hul.harvard.edu), the [Berkman Center for
Internet &amp; Society](http://cyber.law.harvard.edu) and the [Arcadia
Fund](http://www.arcadiafund.org.uk)

### Technologies

* [Rails](http://rubyonrails.org/)
* [Bootstrap](http://getbootstrap.com/)

Contributors
------------

[Justin Clark](https://github.com/jdcc)

License
-------

Apache 2.0 - See the LICENSE file for details.

Copyright
---------

Copyright &copy; 2014 President and Fellows of Harvard College
