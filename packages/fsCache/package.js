Package.describe({
  summary: "HTML5 FIleSystem API easy caching"
});

Package.on_use(function (api, where) {
  api.use([
    'standard-app-packages',
    'underscore',
    'iron-router',
    'coffeescript',
    'ui'
  ],[ 'client']);
  api.add_files(['fscache.coffee'], 'client');
  api.export(['FSCache','existsFile','fileSystem'],'client');
});
