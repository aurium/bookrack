Bookrack — Readable ORM built above Knex and Bookshelf
======================================================

There is no intent to reinvent the wheel. This is not another ORM. This is a [Knex](http://knexjs.org) and [Bookshelf](http://bookshelfjs.org) abstraction layer.


--------------------------------------------------------------------------------

TODO
====
* Load table structure to add columns as model instance attributes.
* Add a kinex twin to timestamps on model defFunc, adding related methods to model and instances.
* Auto DB Builder - Create all needed tables in an empty DB. (All `$defModel` data should do the job)
* Knex Migration File Generator - useful as first migration. (All `$defModel` data should do the job)
* Allow different data source definition to a model. (Means a different knex+bookshelf instance)
