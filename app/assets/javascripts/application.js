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

window.TEXT_FIELDS = [
    "common_name",
    "manufacturer_name",
    "scientific_name",
    "category",
    "short_description",
    "long_description",
    "refuse_description",
    "source"
]

window.FLOAT_FIELDS = [
    "refuse_percentage",
    "density",
    "energy",
    "water",
    "protein",
    "carbohydrate",
    "fat",
    "fibers",
    "sugar",
    "alcohol",
    "caffeine",
    "saturated_fat",
    "monounsaturated_fat",
    "polyunsaturated_fat",
    "trans_fat",
    "cholesterol",
    "omega_3",
    "epa",
    "dpa",
    "dha",
    "ala",
    "omega_6",
    "calcium",
    "iron",
    "magnesium",
    "phosphorus",
    "potassium",
    "sodium",
    "zinc",
    "copper",
    "manganese",
    "selenium",
    "fluoride",
    "vit_a",
    "vit_b1",
    "vit_b2",
    "vit_b3",
    "vit_b5",
    "vit_b6",
    "vit_b7",
    "vit_b9",
    "vit_b12",
    "vit_c",
    "vit_d",
    "vit_e",
    "vit_k",
    "alpha_carotene",
    "beta_carotene"
]

function updateChart (summary) {
    window.overview.series[0].data[0].update(summary.protein()*4);
    window.overview.series[0].data[1].update(summary.carbohydrate()*4);
    window.overview.series[0].data[2].update(summary.fat()*9);
}

function updateDetailChart (food) {
    window.detailChart.series[0].data[0].update(food.protein*4);
    window.detailChart.series[0].data[1].update(food.carbohydrate*4);
    window.detailChart.series[0].data[2].update(food.fat*9);
}

// Ajouter un event se déclenchant à chaque touche de clavier.
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
    // Liste des aliments ajoutés (et leurs valeurs nutritionelles)
    $scope.foods = [];
    $scope.unit = "g";
    $scope.currentFood = {};

    ///////////////////////
    //  CALCUL DU BILAN  //
    ///////////////////////

    function createFunc (j) {
        return function () {
            var r = 0;
            for (var i = $scope.foods.length - 1; i >= 0; i--){
                if ($scope.foods[i].unit == "ml") {
                    r = r + ($scope.foods[i][FLOAT_FIELDS[j]] * $scope.foods[i].quantity / 100.0) * $scope.foods[i].density;
                } else {
                    r = r + ($scope.foods[i][FLOAT_FIELDS[j]] * $scope.foods[i].quantity / 100.0);
                };
            };
            return r;
        }
    }

    for (var j = FLOAT_FIELDS.length - 1; j >= 0; j--){
        $scope[FLOAT_FIELDS[j]] = createFunc(j);
    };

    ///////////////////////////////////
    //  MANIPULATION DE L'INTERFACE  //
    ///////////////////////////////////

    $scope.showSearchBox = function () {
        $('#searchBox').removeClass("hidden");
        $('#confirmBox').addClass("hidden");
    }

    // Montrer la page détaillée d'un aliment.
    $scope.showDetail = function(food) {
        $scope.currentFood = food;
        updateDetailChart(food);
        $(".detail").removeClass("hidden");
    };

    // Masquer la page détaillée (retour à la page principale).
    $scope.hideDetail = function() {
        $(".detail").addClass("hidden");
        $(".summaryDetail").addClass("hidden");
    };

    // Montrer le bilan détaillé.
    $scope.showSummaryDetail = function() {
        // updateDetailChart(food);
        $("#summaryPie").html($("#pie").html());
        $(".summaryDetail").removeClass("hidden");
    };

    $scope.amount = function(food) {
        if (food.unit == "ml") {
            return "" + food.quantity + "ml";
        } else {
            return "" + food.quantity + "g";
        };
    };

    $scope.searchFood = function() {
        if ($scope.foodText.length <= 2) {
            $('.completion').addClass("hidden");
            return;
        }

        $.ajax("/foods.xml?name=" + $scope.foodText, {
            success: function (r) {
                $scope.results = [];
                results = $(r).find("food");

                results.each(function(i) {
                    newFood = {};
                    for (var j = TEXT_FIELDS.length - 1; j >= 0; j--) {
                        newFood[TEXT_FIELDS[j]] = $(results[i]).find(TEXT_FIELDS[j]).text();
                    };
                    for (var j = FLOAT_FIELDS.length - 1; j >= 0; j--) {
                        newFood[FLOAT_FIELDS[j]] = parseFloat($(results[i]).find(FLOAT_FIELDS[j]).text());
                        if (isNaN(newFood[FLOAT_FIELDS[j]])) {
                            newFood[FLOAT_FIELDS[j]] = 0;
                        };
                    };
                    // console.log(newFood);
                    $scope.results.push(newFood);

                    $scope.unit = "g";
                    if (newFood.density == 0) {
                        $("#ml").addClass("hidden");
                    } else {
                        $("#ml").removeClass("hidden");
                    };

                    // $scope.results.push({
                    //     text:     $(results[i]).find("long_description").text(),
                    //     proteins: parseFloat($(results[i]).find("protein").text()),
                    //     carbs:    parseFloat($(results[i]).find("carbohydrate").text()),
                    //     fat:      parseFloat($(results[i]).find("fat").text())
                    // });
                });

                $('.completion').removeClass("hidden");
                $scope.$apply();
                $('#quantity')[0].focus();
            }
        });
    };

    // cette fonction est executée quand la fonction de recherche est
    // validée.
    $scope.addFood = function() {
        $scope.currentFood.quantity = parseFloat($scope.quantity);
        $scope.currentFood.unit = $scope.unit;
        // if ($scope.currentFood.density == 0) {
        //     $scope.currentFood.liquid == false;
        // } else {
        //     $scope.currentFood.liquid == true
        // };
        $scope.foods.push($scope.currentFood);
        $scope.showSearchBox();
        $scope.foodText = '';
        $scope.quantity = '';
        updateChart($scope);
    };

    // retirer un aliment de la liste.
    $scope.removeFood = function(food) {
        for (var i = $scope.foods.length - 1; i >= 0; i--){
            if(food == $scope.foods[i]) {
                $scope.foods.splice(i, 1);
            }
        };
        updateChart($scope);
    };

    $scope.selectFood = function (e) {
        $scope.currentFood = e;
        $('.completion').addClass("hidden");
        $('#searchBox').addClass("hidden");
        $('#confirmBox').removeClass("hidden");
        $scope.foodText = '';
    }
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
