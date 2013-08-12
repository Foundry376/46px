'use strict';

/* Controllers */

function StreamController($scope, $resource, $browser, $location) 
{
	// Create a new resource that represents a stream. This is where we define the API
	// for retrieving, updating, deleting streams so we can ask for a stream.
    $scope.StreamModel = $resource('http://dev.46px.com/api/stream/top/:pageId',
        {pageId:'%pageId'},
        {get:{method:'GET'}});

	// Set the page number to the first page, and load the first stream. Note that we store
	// the stream contents into $scope.$root rather than just $scope. This means that the
	// stream is preserved as you move forward and backward through the interface—it's not
	// just stored for the current view. That means if you view the stream, drill down to a 
	// thread, and then press back, the stream that was last fetched is still there!
	$scope.pageNumber = 1;
    $scope.StreamModel.get({pageId: $scope.pageNumber}, function($obj) {
    	$scope.$root.stream = $obj
    });
	  
	// Add ourselves as listeners for interface updates. Usually the watch function
	// takes a notification name (so we'd be notified when "X" event occurred), but
	// signing up for the catch-all notification allows us to run code after the 
	// interface has been popluated from a stream update. We need to know
	// when this happens so we can render our HTML5 canvas-based pixel arts.
	$scope.$watch(function(newVal, oldVal, scope) {
        $("canvas").each(function() {
		   var i = new Image();
		   console.log($(this).attr("id"));
		   i.canvas = $(this).attr("id");
		   i.onload = replaceInto;
		   i.src = $(this).attr("href");
		});
  	});
  
    // Function bound to the left and right arrow buttons. Called with shift = -1 or 1
    // to shift the page number and then reload the stream.
    $scope.shiftPage = function (shift) {
		this.pageNumber  += shift;

		// for some reason we have to bake the page number into a local variable...
		var p = this.pageNumber;
        $scope.$root.stream = $scope.Stream.get({pageId: p});
    };
    
    // Function bound to the thread click event. This function moves the tapped thread
    // into the root scope so it can be accessed after we load the next view, and then
    // changes the url to show the thread view.
    $scope.openThread = function (threadIndex) {
    	$scope.$root.thread = $scope.thread = $scope.stream.threads[threadIndex];
    	$location.path('thread/'+$scope.thread.id);
    	console.log($scope);
    }
}


function ThreadController($scope, $resource, $routeParams) 
{
	// Create a resource that represents the Thread data source. This defines how
	// we fetch and save thread objects. 
    $scope.ThreadModel = $resource('http://dev.46px.com/api/thread/:threadId',
        {threadId:'%threadId'},
        {get:{method:'GET'}});

	if ($scope.thread != null)
		console.log("Already have thread!");
	
	// Fetch the thread object. $scope.thread may already be set if we tapped
	// on a thread in the stream view and got here through openThread(). In that case,
	// we only need this request to load all of the response posts, and we'll swap
	// out our local version for the more complete version when it comes in.
	var t = $routeParams.threadId;
	$scope.ThreadModel.get({threadId: t}, function($obj){ 
		// when the model request is complete, replace our cached copy of the thread.
		// The cached copy is probably just a stub from the /streams json. 
		$scope.thread = $obj;
	});
}
