/*global angular*/



angular.module('ve.controlpanel', ['ui.bootstrap', 'ui.grid']);

angular.module('ve.controlpanel').controller('LogGridController', function ($scope) {
    'use strict';
    $scope.myData = [
        {
            "firstName": "Cox",
            "lastName": "Carney",
            "company": "Enormo",
            "employed": true
        },
        {
            "firstName": "Lorraine",
            "lastName": "Wise",
            "company": "Comveyer",
            "employed": false
        },
        {
            "firstName": "Nancy",
            "lastName": "Waters",
            "company": "Fuelton",
            "employed": false
        }];
});

                                             
angular.module('ve.controlpanel').controller('NavController', function ($scope) {
    'use strict';
    $scope.pills = [
        {title: 'Home', pclass: 'active'},
        {title: 'Cron Jobs', pclass: ''}
    ];
    
    
    //$scope.oneAtATime = true;

  /*$scope.groups = [
    {
      title: 'Dynamic Group Header - 1',
      content: 'Dynamic Group Body - 1'
    },
    {
      title: 'Dynamic Group Header - 2',
      content: 'Dynamic Group Body - 2'
    }
  ];

  $scope.items = ['Item 1', 'Item 2', 'Item 3'];

  $scope.addItem = function() {
    var newItemNo = $scope.items.length + 1;
    $scope.items.push('Item ' + newItemNo);
  };

  $scope.status = {
    isFirstOpen: true,
    isFirstDisabled: false
  };*/
});

/*(function () {
    $(document).ready(function () {
        //alert("hello");
        console.log("VegApp Started");
    });
})();*/
