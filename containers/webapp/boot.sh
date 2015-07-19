#!/bin/bash

rake assets:precompile
bundle exec unicorn_rails -c config/unicorn.rb
