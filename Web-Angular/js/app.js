'use strict';


// Declare app level module which depends on filters, and services
angular.module('myApp', ['ngResource', 'ng', 'myApp.filters', 'myApp.services', 'myApp.directives']).
  config(['$routeProvider', function($routeProvider) {
	$routeProvider.when('/stream', {template: 'partials/stream.html', controller: StreamController});
	$routeProvider.when('/thread/:threadId', {template:'partials/thread.html', controller: ThreadController});
    $routeProvider.otherwise({redirectTo: '/stream'});
  }]);
