# Yet Another Configuration Gem (yaconfig)

Why another one? I wanted a config gem for my little utilities I write for people that was both simple,
but still provided a file loading interface that would merge configuration files.

The config store is mostly a [SymbolTable](https://github.com/mjijackson/symboltable) wrapped with some utilities.

## Installation

Add this line to your application's Gemfile:

    gem 'yaconfig'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yaconfig

And require it:

    require 'yaconfig'

## Usage

In it's most basic useage it's simply a class that acts as a hash
with some magic to both convert the hash keys into symbols, and to
dynamically create accessors.
    
    conf = Yaconfig::Configuration.new
    conf.something = 'my configuration value'
    conf.email = 'so-and-so@stupid-spammers.com'
    
### New

The new accepts both a hash as an argument to be converted into the
configuration, and the block style as well.

    conf = Yaconfig::Configuration.new({:email => 'so-and-so@stupid-spammers.com',
        :otherthing => 'other value'})

    conf = Yaconfig::Configuration.new { |c|
        c.something = 'my configuration value'
        c.email = 'so-and-so@stupid-spammers.com'
    }

### Access to Data

You can use various forms to access the data, both the \[\] hash notation, and the
quicker dot notation. This is for both setting and reading.

    puts conf.email
    puts conf[:email]

#### Nesting

The class allows nesting, so you can do the following:

    conf.datacenter = {}
    conf.datacenter.address = '555 Wheee Street'
    conf.datacenter.phone_number = '555-555-5555'

Note the first line. I experimented with auti-creating the middle elements of these, such 
as the datacenter here, but that caused non-existant elements to no longer return `nil`. 
So as a limitation before you can assign to a sub container, you must initialize it.

### Loading Files

One of the important features of the gem is the ability to load and merge configurations. 
It supports two formats: ruby and json.

#### Ruby

Ruby configuration files are simply evaluated with a `config` object accessable to the file.
It is not really sandboxed at all. So don't use this if you don't trust the source of your
config files.

In your program:

    conf.load_config(
        "./%basename%.conf",
        "%basedir%/../etc/%basename%.conf",
        "%basedir%/../etc/%basename%/%basename%.conf", # debian style
        "/etc/%basename%.conf",
        "/etc/%basename%/%basename%.conf",
        "~/.%basename%.rc"
        )

Substitutions:
* %basename% - This is the command the user called, minus the extension .rb if it exists.
* %basedir% - This is the directory the command was in.
* ~ - User's home directory.

This will attempt to load each of the files in order, and the results get merged. So if you
want ~/.myapp.rc to have final say, you list it last.

The config file can do anything ruby can do, for better or worse. An example:

    config.movie = 'The Sound of Music'
    config.list = 1..10

If the config file does not exist, it's skipped, so it's ok to list anything you might want.

#### JSON

Good for automatically generated configs, or if you don't trust the ruby someone might stick in
their config.

From raw JSON in a string:

    conf.configure_json(json_data)

From files:

    conf.load_config_json(
        "./%basename%.json",
        "%basedir%/../etc/%basename%.json",
        "%basedir%/../etc/%basename%/%basename%.json", # debian style
        "/etc/%basename%.json",
        "/etc/%basename%/%basename%.json",
        "~/.%basename%.rc"
        )

#### Blocks

If you want to pass it another block to merge in, you can use:

    conf.configure {
        # ...
    }
    
Just like with new. See above.

#### Hases

You can feed it additional hashes with `merge!`

    conf.merge!({:whatever => 'something'})

### Other stuff

I included a short cut to pretty-print in json format the config for debugging
use. You can use it with:

    puts conf.to_json_pretty

If you don't like the way I come up with the base-name, you can set it manually with:

    conf.basename = 'myProgram'

Naturally you can check to see what it generated on it's own with:

    puts conf.basename

You can set the verbosity of the gem with:

    conf.verbose = 1

It expects `nil`, `false`, or a integer. 1 causes it to tell you what config files it
loaded. 2 causes it to also tell you which ones it could not load.

### Suggested Usage

Not that I want to tell you how to code, but this is how I use it:

    # I like to assign it to a constant to make it stand out, and accessable
    CFG = Yaconfig::Configuration.new { |c|
        # Create any sub containers that you expect your users to use.
        c.datacenter = {}
        c.user_info = {}
        
        # Set any defaults.
        c.email = 'no-reply@no-such-domain.com'
    }

Then load your user's configs as shown above.

If you are parsing options with something like Slop or whatever floats your boat, it
becomes trivial to add a config switch:

    CFG.load_config(opts[:config]) if opts[:config]

## Todo

* Fix any bugs that are found.
* Do proper in-line documentation in the code.

## Contributing
I'm not scared of feedback. Usually. I only bite a little. :)

### By Suggesting Improvments and Reporting Bugs

Use the github issue tracker. No promises on how fast I'll deal with either. I have
a job and all that. :)

### By Writing Code

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
