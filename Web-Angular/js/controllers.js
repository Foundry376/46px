'use strict';

/* Controllers */

function StreamController($scope, $resource, $browser) {
    $scope.Stream = $resource('http://dev.46px.com/api/stream/top/:pageId',
        {pageId:'%pageId'},
        {get:{method:'GET'}});

	$scope.pageNumber = 1;
    $scope.stream = $scope.Stream.get({pageId: $scope.pageNumber});
	  
	$scope.$watch(function(newVal, oldVal, scope) {
        $("canvas").each(function() {
		   var i = new Image();
		   console.log($(this).attr("id"));
		   i.canvas = $(this).attr("id");
		   i.onload = replaceInto;
		   i.src = $(this).attr("href");
		});
  	});
  
    $scope.shiftPage = function (shift) {
		this.pageNumber  += shift;
		var p = this.pageNumber;
        this.stream = $scope.Stream.get({pageId: p});
    };
}


function ThreadController($scope, $resource, $routeParams) {

    $scope.Thread = $resource('http://dev.46px.com/api/thread/:threadId',
        {threadId:'%threadId'},
        {get:{method:'GET'}});

	var t = $routeParams.threadId;
    $scope.thread = $scope.Thread.get({threadId: t});
}
