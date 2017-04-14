
## Create New v5.1 Rails App

```shell
$ gem install bundler

$ cd ~/Projects
$ git clone https://github.com/rails/rails.git
$ cd rails
$ git checkout 5-1-stable
$ git pull
$ ./railties/exe/rails new ~/Desktop/lovesjs --dev --webpack
```

## About Webpacker

https://github.com/rails/webpacker

> Webpacker makes it easy to use the JavaScript preprocessor and bundler Webpack 2.x.x+ to manage application-like JavaScript in Rails. It coexists with the asset pipeline, as the primary purpose for Webpack is app-like JavaScript, not images, css, or even JavaScript Sprinkles (that all continues to live in app/assets). It is, however, possible to use Webpacker for CSS and images assets as well, in which case you may not even need the asset pipeline. This is mostly relevant when exclusively using component-based JavaScript frameworks.

> It's designed to work with Rails 5.1+ and makes use of the Yarn dependency management that's been made default from that version forward.

> ...Webpack is app-like JavaScript, not images, css...
> ...It is, however, possible to use Webpacker for CSS and images assets as well...
> ...relevant when exclusively using component-based JavaScript frameworks...
> ...makes use of the Yarn dependency management...

Requires the following dependencies among others.

* Node.js 6.4.0+
* Yarn

```shell
$ node -v
v7.0.0

$ brew install yarn
$ sudo port install yarn
yarn --version
0.22.0
```

Webpacker is being updated often. Change Gemfile to

```ruby
gem 'webpacker', github: 'rails/webpacker'
```

Then update everything in your app. Allow all overwrite and commit.

```
$ ./bin/rails webpacker install
```

Example of tasks available.

```
$ rails webpacker
Available webpacker tasks are:
webpacker:install             Installs and setup webpack with yarn
webpacker:compile             Compiles webpack bundles based on environment
webpacker:check_node          Verifies if Node.js is installed
webpacker:check_yarn          Verifies if yarn is installed
webpacker:verify_install      Verifies if webpacker is installed
webpacker:yarn_install        Support for older Rails versions. Install all JavaScript dependencies as specified via Yarn
webpacker:install:react       Installs and setup example react component
webpacker:install:vue         Installs and setup example vue component
```

## Setting up demo pages.

```shell
$ rails server
```

Visit [http://0.0.0.0:3000](http://0.0.0.0:3000) Now setup two test pages.

* http://0.0.0.0:3000/react
* http://0.0.0.0:3000/glimmer


## Examine Config Files

Lets browse thru all `config/webpack` files. Highlights.

* The `config/webpack/configuration.js` seems to be the root "config".
* Has a babel loader.
* Has other normal Rails loaders. ERB, CoffeeScript, Sass, and Assets.


## Create Basic React Component

```
$ ./bin/rails webpacker:install:react
Webpacker is installed 🎉🍰
Using /Users/kencollins/Desktop/lovesjs/config/webpack/paths.yml file for setting up webpack paths
Copying react loader to /Users/kencollins/Desktop/lovesjs/config/webpack/loaders
      create  config/webpack/loaders/react.js
Copying .babelrc to app root directory
      create  .babelrc
Copying react example entry file to /Users/kencollins/Desktop/lovesjs/app/javascript/packs
      create  app/javascript/packs/hello_react.jsx
Installing all react dependencies
         run  ./bin/yarn add react react-dom babel-preset-react from "."
Yarn executable was not detected in the system.
Download Yarn at https://yarnpkg.com/en/docs/install
Webpacker now supports react.js 🎉
```

Hmm, the ./bin/yarn stub wants to call `yarnpkg`. Wonder if that is the old name. Change to:

```ruby
ypath = ENV['YARN_PATH'] || '/opt/local/bin/yarn'
exec "#{ypath} #{ARGV.join(" ")}"
```

Now I see good output.

```
Installing all react dependencies
         run  ./bin/yarn add react react-dom babel-preset-react from "."
yarn add v0.22.0
info No lockfile found.
[1/4] 🔍  Resolving packages...
[2/4] 🚚  Fetching packages...
[3/4] 🔗  Linking dependencies...
[4/4] 📃  Building fresh packages...
success Saved lockfile.
success Saved 34 new dependencies.
...
```

Wow! Along with adding the `app/javascript/packs/hello_react.jsx`, we also updated our package.json too. Neat!

```diff
--- a/package.json
+++ b/package.json
@@ -1,5 +1,9 @@
 {
   "name": "lovesjs",
   "private": true,
-  "dependencies": {}
+  "dependencies": {
+    "babel-preset-react": "^6.24.1",
+    "react": "^15.5.4",
+    "react-dom": "^15.5.4"
+  }
 }
```

Also noticed it created a `./node_modules` directory... as it should have!

Test the setup. From Webpacker docs:

> If you would rather forego the advanced features and serve your javascript packs directly from the rails server, you may use `./bin/webpack-watcher` instead, but make sure to disable the Dev Server in `config/webpack/development.server.yml`, otherwise script tags will keep pointing to `localhost:8080` and won't load properly.

So we do that.

```diff
--- a/config/webpack/development.server.yml
+++ b/config/webpack/development.server.yml
@@ -1,6 +1,6 @@
 # Restart webpack-dev-server if you make changes here
 default: &default
-  enabled: true
+  enabled: false
   host: localhost
   port: 8080
```

Now to see if it works. Darn!

```shell
$ ./bin/webpack-watcher
sh: /Users/kencollins/Desktop/lovesjs/node_modules/.bin/webpack: No such file or directory

$ find . -name webpack
./bin/webpack
./config/webpack
```

Ah... due to the Yarn bin issue, the install never ran. Now do this again.


```shell
$ ./bin/rails webpacker:install
```

And now package.json GOT MUCH BIGGER! Now re-run

```
$ ./bin/webpack-watcher
  0% compiling
Webpack is watching the files…

 10% building modules 1/2 modules 1 active .../app/javascript/packs/hello_react.jsx(node:94085) DeprecationWarning: loaderUtils.parseQuery() received a non-string value which can be problematic, see https://github.com/webpack/loader-utils/issues/56
parseQuery() will be replaced with getOptions() in the next major version of loader-utils.
Hash: 6baa9ebd4303632c0aeb
Version: webpack 2.3.3
Time: 1981ms
             Asset       Size  Chunks                    Chunk Names
    hello_react.js     769 kB       0  [emitted]  [big]  hello_react
    application.js     3.4 kB       1  [emitted]         application
hello_react.js.map     881 kB       0  [emitted]         hello_react
application.js.map    3.35 kB       1  [emitted]         application
     manifest.json  198 bytes          [emitted]
   [1] ./~/fbjs/lib/warning.js 2.1 kB {0} [built]
  [14] ./~/react/lib/ReactElement.js 11.2 kB {0} [built]
  [17] ./~/react-dom/lib/ReactReconciler.js 6.21 kB {0} [built]
  [18] ./~/react/lib/React.js 3.32 kB {0} [built]
  [80] ./~/react-dom/index.js 59 bytes {0} [built]
  [81] ./~/react/react.js 56 bytes {0} [built]
  [82] ./app/javascript/packs/application.js 515 bytes {1} [built]
  [83] ./app/javascript/packs/hello_react.jsx 709 bytes {0} [built]
 [113] ./~/react-dom/lib/ReactDOM.js 5.14 kB {0} [built]
 [169] ./~/react-dom/lib/renderSubtreeIntoContainer.js 422 bytes {0} [built]
 [173] ./~/react/lib/ReactClass.js 26.9 kB {0} [built]
 [174] ./~/react/lib/ReactDOMFactories.js 5.53 kB {0} [built]
 [175] ./~/react/lib/ReactPropTypes.js 500 bytes {0} [built]
 [177] ./~/react/lib/ReactPureComponent.js 1.32 kB {0} [built]
 [178] ./~/react/lib/ReactVersion.js 350 bytes {0} [built]
    + 168 hidden modules
```

Load http://0.0.0.0:3000/react


## Results

Since the development file has source maps and comes in around 700KB.

Compile production ENV to see how that goes.

```shell
$ RAILS_ENV=production NODE_ENV=production ./bin/rails webpacker:compile

$ ll public/packs
-rw-r--r--   1 kencollins  staff   139K Apr 13 20:42 hello_react-73e061e350fc816408b7.js
-rw-r--r--   1 kencollins  staff    43K Apr 13 20:42 hello_react-73e061e350fc816408b7.js.gz
```

* Can that file be smaller?
* How do I make a component that I can drop on the page with?

```html
<Hello name="React" />
```

