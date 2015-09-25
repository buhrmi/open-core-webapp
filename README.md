[![Build Status](https://travis-ci.org/open-core/webapp.svg?branch=master)](https://travis-ci.org/open-core/webapp)

# open-core/webapp
A web application to interact with the [Core](http://github.com/buhrmi/core)/[Stellar](http://www.stellar.org/galaxy) Consensus Network.

# See it running

* Against the [Open Core](http://github.com/open-core/network) Network: http://open-core.org
* Against the [Stellar](http://www.stellar.org/galaxy) Network: http://stellar-core.org

# Run it locally

## Prerequisits

* Install [Meteor](http://meteor.com/install)
* Access to a Core Postgres database. You can set one up yourself. See [here](https://github.com/buhrmi/core/blob/master/INSTALL.md) for installation instructions.
* It also helps to be familiar with [Stellar](https://www.stellar.org/galaxy/)

## Clone and run

    git clone https://github.com/buhrmi/open-core.git
    cd open-core
    CORE_DB_URL=postgres://[username]:[password]@[address-of-core-db]/[databasename] TX_EDNPOINT=http://ip-of-core-node:11626/tx?blob= meteor

# Deploy

For easy deployments, [Meteor UP](https://github.com/arunoda/meteor-up) is used. So far, only Ubuntu 14.04 x64 has been tested. To deploy the app in production mode to your own server, follow these steps:

* Install Meteor UP: `npm install -g mup`
* Install your SSH public key on the server.
* Rename the `mup.json.template` file to `mup.json` and configure it to match your server configuration.
* Run `mup setup`. This will bootstrap your server for deployment. You only need to do this once.
* Run `mup deploy` to deploy the app. Now you should be good to go.

# I can't even...

If you have questions about any of this, join us in the Stellar developer chat over at [Slack](https://stellar-public.slack.com/messages/dev/)

# License

Yup.
