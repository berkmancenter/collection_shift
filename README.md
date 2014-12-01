CollectionShift
===============

Description
-----------

CollectionShift is a tool to help plan the shifting of collections of library items (primarily books and serials) from one shelf space to another.

Code Repository
---------------

The code lives in the Berkman Center's [GitHub repo](https://github.com/berkmancenter/collection_shift).

User Documentation
------------------

We're in the process of finalizing user documentation, but once it's up this
will get updated with a pointer to it.

Requirements
------------

* Git
* Ruby >= 2
* Bundler
* PostgreSQL (including -dev packages)

Bundler should take care of the rest.

Setup
-----

* Install requirements (see above)
* Checkout the code
  * `git clone https://github.com/berkmancenter/linkomatic`
  * `cd linkomatic`
* Install libraries
  * `bundle install`
* Configure the database
  * `cp config/database.yml.example config/database.yml`
  * Setup a postgres user and update `config/database.yml` accordingly
  * `rake db:create`
  * `rake db:setup`
* Update the devise configs
  * Use `rake secret` to generate a new secret key and add it to
    `config/initializers/devise.rb`
  * Update the `config.mailer_sender` in `config/initializers/devise.rb`

Tested Configurations
---------------------

* Phusion Passenger, Ruby 2.1.2, Apache 2.2, Ubuntu 12.04 LTS
* Phusion Passenger, Ruby 2.1.4, Apache 2.4, Ubuntu 14.04 LTS

Issue Tracker
-------------

We maintain a closed-to-the-public [issue tracker](https://cyber.law.harvard.edu/projectmanagement/projects/collectionshift). Any additional issues can be added to the [GitHub issue tracker](https://github.com/berkmancenter/collectionshift/issues).

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
* [PostgreSQL](http://www.postgresql.org/)

Contributors
------------

[Justin Clark](https://github.com/jdcc)

License
-------

Apache 2.0 - See the LICENSE file for details.

Copyright
---------

Copyright &copy; 2014 President and Fellows of Harvard College
