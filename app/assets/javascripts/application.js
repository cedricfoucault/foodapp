// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require_tree .

angular.module('FoodApp', []).
directive('onKeyup', function() {
    return function(scope, elm, attrs) {
        elm.bind("keyup", function() {
            scope.$apply(attrs.onKeyup);
        });
    };
});

// Voir http://angularjs.org/ pour la fonction suivante.
function FoodCtrl($scope) {
    $scope.results = [];

    // Liste des aliments ajoutés (et leurs valeurs nutritionelles)
    $scope.foods = [
    {
        text: "Banana",
        proteins: 10,
        carbs: 50,
        fat: 20
    },
    {
        text: "Chicken",
        proteins: 80,
        carbs: 0,
        fat: 20
    }
    ];

    // bilan des protéines
    $scope.proteins = function() {
        var r = 0;
        for (var i = $scope.foods.length - 1; i >= 0; i--){
            r = r + $scope.foods[i].proteins;
        };
        return r;
    };

    // bilan des glucides
    $scope.carbs = function() {
        var r = 0;
        for (var i = $scope.foods.length - 1; i >= 0; i--){
            r = r + $scope.foods[i].carbs;
        };
        return r;
    };

    // bilan des lipides
    $scope.fat = function() {
        var r = 0;
        for (var i = $scope.foods.length - 1; i >= 0; i--){
            r = r + $scope.foods[i].fat;
        };
        return r;
    };

    $scope.searchFood = function() {
        if ($scope.foodText.length > 2) {
            $.ajax("/foods.xml?name=" + $scope.foodText, {
                success: function (r) {
                    $scope.results = [];

                    r = $(r);
                    results = r.find("food");

                    results.each(function(i) {
                        console.log(results[i]);
                        $scope.results.push({
                            text:     $(results[i]).find("common_name").text(),
                            proteins: 0, // 0 étant une valeur bateau pour le moment
                            carbs:    0,
                            fat:      0
                        });
                    });

                    $('.completion').removeClass("hidden");
                    $scope.$apply();
                }
            });
        } else {
            $('.completion').addClass("hidden");
        };
    };

    // cette fonction est executée quand la fonction de recherche est
    // validée.
    $scope.addFood = function() {
        $.ajax("/foods/" + $scope.foodText + ".xml", {
            success: function (r) {
                r = $(r);
                // TODO: traiter la réponse (<food>...</food>)

                // ajouter les donnéees extraites à la liste d'aliments:
                $scope.foods.push({
                    text:     r.find("common_name").text(),
                    proteins: 0, // 0 étant une valeur bateau pour le moment
                    carbs:    0,
                    fat:      0
                });
                $scope.$apply();
                // $('.dynamicsparkline').sparkline("html", {
                //   type: "pie"
                // });
            }
        });

        $scope.foodText = '';
    };

    // retirer un aliment de la liste
    $scope.removeFood = function(food) {
        for (var i = $scope.foods.length - 1; i >= 0; i--){
            if(food == $scope.foods[i]) {
                $scope.foods.splice(i, 1);
            }
        };
    };
};

// la page est divisee en 3 sections (resume des nutriments, liste
// d'aliments, champ de recherche).
// la liste d'aliments doit prendre toute la hauteur de la page, moins
// le resume et le champ de recherche. Cette fonction ajuste la hauteur
// de la section "liste".
function layout () {
    $(".FoodList").css({
        height: $(window).height()
                - $(".FoodSummary").innerHeight()
                - $(".Search").innerHeight()
    });
}

// lorsque la page est chargée, ajuster la hauteur de la liste d'aliments,
// et redimensionner cette liste quand la taille de la fenetre change.
$(function () {
    layout();
    $(window).bind('resize', layout);
    var myvalues = [10,5,2];
    // $('.dynamicsparkline').sparkline("html", {
    //   type: "pie"
    // });
});
