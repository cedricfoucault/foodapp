//= require jquery
//= require underscore
//= require backbone
//= require bootstrap.min
//= require processing
//= require enquire.min

document.NUTRIENTS_DROPDOWN = [
    "energy",
    "protein",
    {
        category: "Carbohydrates",
        nutrients: ["carbohydrate", "fibers", "sugar"]
    },
    {
        category: "Fatty Acids",
        nutrients: ["fat", "monounsaturated_fat", "polyunsaturated_fat", "trans_fat", "omega_3", "ala", "epa", "dpa", "dha", "omega_6", "cholesterol"],
    },
    {
        category: "Minerals",
        nutrients: ["calcium", "iron", "sodium", "potassium", "magnesium", "phosphorus", "zinc", "copper", "manganese", "selenium", "fluoride"]
    },
    {
        category: "Vitamins",
        nutrients: ["vit_a", "vit_b1", "vit_b2", "vit_b3", "vit_b5", "vit_b6", "vit_b7", "vit_b9", "vit_b12", "vit_c", "vit_d", "vit_e", "vit_k", "alpha_carotene", "beta_carotene"]
    },
    "alcohol",
    "caffeine",
    "water",
]

document.NUTRIENTS= {
    "energy": {
        "name": "calories",
        "unit": "kcal"
    },
    "water": {
        "name": "water",
        "unit": "g"
    },
    "protein": {
        "name": "protein",
        "unit": "g"
    },
    "carbohydrate": {
        "name": "total carbohydrate",
        "unit": "g"
    },
    "fat": {
        "name": "total fat",
        "unit": "g"
    },
    "fibers": {
        "name": "fiber",
        "unit": "g"
    },
    "sugar": {
        "name": "sugars",
        "unit": "g"
    },
    "alcohol": {
        "name": "alcohol",
        "unit": "g"
    },
    "caffeine": {
        "name": "caffeine",
        "unit": "g"
    },
    "saturated_fat": {
        "name": "saturated fat",
        "unit": "g"
    },
    "monounsaturated_fat": {
        "name": "monounsaturated fat",
        "unit": "g"
    },
    "polyunsaturated_fat": {
        "name": "polyunsaturated fat",
        "unit": "g"
    },
    "trans_fat": {
        "name": "trans fat",
        "unit": "g"
    },
    "cholesterol": {
        "name": "cholesterol",
        "unit": "mg"
    },
    "omega_3": {
        "name": "total omega-3",
        "unit": "mg"
    },
    "epa": {
        "name": "EPA omega-3",
        "unit": "mg"
    },
    "dpa": {
        "name": "DPA omega-3",
        "unit": "mg"
    },
    "dha": {
        "name": "DHA omega-3",
        "unit": "mg"
    },
    "ala": {
        "name": "ALA omega-3",
        "unit": "mg"
    },
    "omega_6": {
        "name": "total omega-6",
        "unit": "mg"
    },
    "calcium": {
        "name": "calcium",
        "unit": "mg"
    },
    "iron": {
        "name": "iron",
        "unit": "mg"
    },
    "magnesium": {
        "name": "magnesium",
        "unit": "mg"
    },
    "phosphorus": {
        "name": "phosphorus",
        "unit": "mg"
    },
    "potassium": {
        "name": "potassium",
        "unit": "mg"
    },
    "sodium": {
        "name": "sodium",
        "unit": "mg"
    },
    "zinc": {
        "name": "zinc",
        "unit": "mg"
    },
    "copper": {
        "name": "copper",
        "unit": "mg"
    },
    "manganese": {
        "name": "manganese",
        "unit": "mg"
    },
    "selenium": {
        "name": "selenium",
        "unit": "mg"
    },
    "fluoride": {
        "name": "fluoride",
        "unit": "mg"
    },
    "vit_a": {
        "name": "vitamin A",
        "unit": "µg"
    },
    "vit_b1": {
        "name": "vitamin B1",
        "unit": "µg"
    },
    "vit_b2": {
        "name": "vitamin B2",
        "unit": "µg"
    },
    "vit_b3": {
        "name": "vitamin B3",
        "unit": "µg"
    },
    "vit_b5": {
        "name": "vitamin B5",
        "unit": "µg"
    },
    "vit_b6": {
        "name": "vitamin B6",
        "unit": "µg"
    },
    "vit_b7": {
        "name": "vitamin B7",
        "unit": "µg"
    },
    "vit_b9": {
        "name": "vitamin B9",
        "unit": "µg"
    },
    "vit_b12": {
        "name": "vitamin B12",
        "unit": "µg"
    },
    "vit_c": {
        "name": "vitamin C",
        "unit": "µg"
    },
    "vit_d": {
        "name": "vitamin D",
        "unit": "µg"
    },
    "vit_e": {
        "name": "vitamin E",
        "unit": "µg"
    },
    "vit_k": {
        "name": "vitamin K",
        "unit": "µg"
    },
    "alpha_carotene": {
        "name": "alpha carotene",
        "unit": "µg"
    },
    "beta_carotene": {
        "name": "beta carotene",
        "unit": "µg"
    }
};

$(function() {
    String.prototype.capitalize = function() {
        return this.replace(/(?:^|\s)\S/g, function(a) { return a.toUpperCase(); });
    };
    
    
    var MenuItem = Backbone.Model.extend({
      defaults: {
        "unit": 'g'
      }
    });
  
    var MenuItems = Backbone.Collection.extend({
      model: MenuItem
    });
    
    // var menuItems = new MenuItems();
    
    var MenuItemView = Backbone.View.extend({
      className: "menuItem alter",
      
      initialize: function() {
        this.listenTo(this.model, 'change', this.render);
      },
      
      render: function() {
        var html = _.template($('#menuItemTemplate').html(), {menuItem: this.model});
        this.$el.html(html);
        return this;
      },
      
      events: {
        "change .amount": "amountChange",
      },
      
      amountChange: function(e) {
        amount = $(e.currentTarget).val();
        this.model.set("amount", amount);
      },
    });
    
    var MenuItemsView = Backbone.View.extend({
      initialize: function() {
        this.listenTo(this.collection, 'add', this.render);
        this.listenTo(this.collection, 'remove', this.render);
        this.listenTo(this.collection, 'reset', this.render);
        this.listenTo(this.collection, 'sort', this.render);
      },
      
      render: function() {
        this.$el.html('');
        this.collection.each(this.renderOne, this);
        return this;
      },
      
      renderOne: function(model) {
        var row = new MenuItemView({model:model, id:model.cid});
        this.$el.append(row.render().$el);
        return this;
      },
      
      events: {
        "click .deleteItem": "deleteClicked"
      },
      
      deleteClicked: function(e) {
        e.preventDefault();
        itemCid = $(e.currentTarget).closest(".menuItem").attr('id');
        this.collection.remove(itemCid);
      }
    });
    
    // var menuItemsView = new MenuItemsView({
    //   collection: menuItems,
    //   el: $(".menuItems")[0]
    // });
  
    var Food = Backbone.Model.extend({
    });
  
    var Foods = Backbone.Collection.extend({
      model: Food,
      url: '/foods.json',
      search: function(query, success) {
        this.fetch({reset: true, data: {name: query}, success: success});
      },
    });
    
    var foods = new Foods();
  
    var Search = Backbone.View.extend({
      id: "search",
      
      render: function() {
          var html = _.template($('#searchTemplate').html());
          this.$el.html(html);
          return this;
      },
      
      events: {
        "keyup #searchInput": "searchFood",
        "click .searchResult": "addFood",
        // "click #addFood": "addFood",
        // "click #resetSearch": "clickReset"
      },
    
      searchFood: function(e) {
        var query = this.$("#searchInput").val();
        if (query.length <= 2) {
          this.$("#searchResults").addClass("hidden");
          return;
        } else {
          var that = this;
          foods.search(query, function() {
            var template = _.template($('#searchResultsTemplate').html(), {results: foods});
            that.$("#searchResults").html(template);
            that.$("#searchResults").removeClass("hidden");
          });
        }
      },
      
      // selectFood: function(e) {
      //   this.currentFood = foods.get(e.currentTarget.id);
      //   this.$("#searchResults").addClass("hidden");
      //   this.$("#searchBox").addClass("hidden");
      //   this.$("#addFood").removeAttr("disabled");
      //   this.$("#searchInput").val('');
      //   this.$("#searchResults").html('');
      //   this.$("#selectedFood").text(this.currentFood.get('long_description'));
      //   this.$("#confirmBox").removeClass("hidden");
      // },
    
      addFood: function(e) {
        e.preventDefault();
        // var menuItem = new MenuItem({food: this.currentFood});
        selectedFood = foods.get(e.currentTarget.id);
        // this.menuItems.add({food: this.currentFood});
        var menuItem = new MenuItem({food: selectedFood});
        menuItem.menuCid = this.menuItems.menuCid;
        this.menuItems.add(menuItem);
        this.resetSearch();
      },
      
      // clickReset: function(e) {
      //   e.preventDefault();
      //   this.resetSearch();
      // },
      
      resetSearch: function() {
        // this.currentFood = null;
        this.$("#searchResults").removeClass("hidden");
        this.$("#searchBox").removeClass("hidden");
        // this.$("#addFood").attr('disabled','disabled');
        // this.$("#confirmBox").addClass("hidden");
        // this.$("#selectedFood").text('');
        this.$("#searchInput").val('');
        this.$("#searchResults").html('');
      },
    })
  
    // var search = new Search({el: $("#search")[0]});
    
    
    var Menu = Backbone.Model.extend({
      defaults: {
        "amount": 1,
      }
    });
    
    var Menus = Backbone.Collection.extend({
      model: Menu,
    });
    
    var defaultMenus = JSON.parse('[{"name":"McDo Best Of","menuItems":[{"food":{"ala":614,"alcohol":null,"alpha_carotene":null,"beta_carotene":null,"caffeine":null,"calcium":120,"carbohydrate":26.39,"category":"Fast Foods","cholesterol":32,"common_name":null,"copper":0.066,"created_at":"2013-02-02T21:05:13Z","density":null,"dha":61,"dpa":5,"energy":282,"epa":30,"fat":14.64,"fibers":1.4,"fluoride":null,"id":6555,"iron":1.56,"long_description":"McDONALD\'S, FILET-O-FISH","magnesium":27,"manganese":0.262,"manufacturer_name":"McDonald\'s Corporation","monounsaturated_fat":4.005,"omega_3":null,"omega_6":null,"pg_search_rank":0.156613,"phosphorus":137,"polyunsaturated_fat":5.952,"potassium":220,"protein":11.26,"refuse_description":null,"refuse_percentage":null,"saturated_fat":2.833,"scientific_name":null,"selenium":25.5,"short_description":"MCDONALD\'S, FLT-O-FSH","sodium":434,"source":"USDA","sugar":3.67,"textsearchable_col":"\'filet\':10 \'filet-o-fish\':9 \'fish\':12 \'flt\':4 \'flt-o-fsh\':3 \'fsh\':6 \'mcdonald\':1,7 \'o\':5,11","trans_fat":0.128,"updated_at":"2013-02-02T21:05:13Z","vit_a":null,"vit_b1":0.211,"vit_b12":1.08,"vit_b2":0.13,"vit_b3":2.22,"vit_b5":null,"vit_b6":null,"vit_b7":null,"vit_b9":21,"vit_c":0.3,"vit_d":null,"vit_e":1.17,"vit_k":4.9,"water":45.76,"zinc":0.58},"unit":"g","amount":"100"},{"food":{"ala":382,"alcohol":null,"alpha_carotene":0,"beta_carotene":0,"caffeine":null,"calcium":19,"carbohydrate":42.58,"category":"Fast Foods","cholesterol":null,"common_name":null,"copper":0.114,"created_at":"2013-02-02T21:05:13Z","density":null,"dha":0,"dpa":0,"energy":323,"epa":0,"fat":15.47,"fibers":3.9,"fluoride":null,"id":6560,"iron":0.8,"long_description":"McDONALD\'S, French Fries","magnesium":37,"manganese":0.249,"manufacturer_name":"McDonald\'s Corporation","monounsaturated_fat":7.379,"omega_3":null,"omega_6":null,"pg_search_rank":0.329844,"phosphorus":127,"polyunsaturated_fat":4.727,"potassium":596,"protein":3.41,"refuse_description":null,"refuse_percentage":null,"saturated_fat":2.271,"scientific_name":null,"selenium":0.4,"short_description":"MCDONALD\'S,FRENCH FR","sodium":189,"source":"USDA","sugar":0.21,"textsearchable_col":"\'fr\':4 \'french\':3,7 \'fri\':8 \'mcdonald\':1,5","trans_fat":0.064,"updated_at":"2013-02-02T21:05:13Z","vit_a":0,"vit_b1":0.18,"vit_b12":null,"vit_b2":0.037,"vit_b3":3.22,"vit_b5":0.59,"vit_b6":0.38,"vit_b7":null,"vit_b9":null,"vit_c":5.6,"vit_d":null,"vit_e":1.38,"vit_k":16,"water":36.63,"zinc":0.51},"unit":"g","amount":"150"},{"food":{"ala":null,"alcohol":0,"alpha_carotene":0,"beta_carotene":0,"caffeine":0,"calcium":2,"carbohydrate":10.14,"category":"Beverages","cholesterol":0,"common_name":"soft drink, white soda, pop","copper":0.001,"created_at":"2013-02-02T21:03:30Z","density":1.0414729403,"dha":0,"dpa":0,"energy":40,"epa":0,"fat":0.02,"fibers":0,"fluoride":55.9,"id":4150,"iron":0.11,"long_description":"Carbonated beverage, SPRITE, lemon-lime, without caffeine","magnesium":1,"manganese":0.002,"manufacturer_name":"The Coca-Cola Company","monounsaturated_fat":0,"omega_3":null,"omega_6":null,"pg_search_rank":0.0759909,"phosphorus":0,"polyunsaturated_fat":0,"potassium":1,"protein":0.05,"refuse_description":null,"refuse_percentage":null,"saturated_fat":0,"scientific_name":null,"selenium":0,"short_description":"CARBONATED BEV,SPRITE,LEMON-LIME,WO/ CAFFEINE","sodium":9,"source":"USDA","sugar":8.98,"textsearchable_col":"\'bev\':7 \'beverag\':15 \'caffein\':13,21 \'carbon\':6,14 \'drink\':2 \'lemon\':10,18 \'lemon-lim\':9,17 \'lime\':11,19 \'pop\':5 \'soda\':4 \'soft\':1 \'sprite\':8,16 \'white\':3 \'without\':20 \'wo\':12","trans_fat":null,"updated_at":"2013-02-02T21:03:30Z","vit_a":0,"vit_b1":0,"vit_b12":0,"vit_b2":0,"vit_b3":0.015,"vit_b5":0,"vit_b6":0,"vit_b7":null,"vit_b9":0,"vit_c":0,"vit_d":0,"vit_e":0,"vit_k":0,"water":89.78,"zinc":0.04},"unit":"g","amount":"500"}],"amount":1},{"name":"Chicken & Potatoes","menuItems":[{"food":{"ala":12,"alcohol":0,"alpha_carotene":0,"beta_carotene":0,"caffeine":0,"calcium":5,"carbohydrate":0,"category":"Poultry Products","cholesterol":64,"common_name":null,"copper":0.027,"created_at":"2013-02-02T21:01:31Z","density":null,"dha":3,"dpa":4,"energy":114,"epa":2,"fat":2.59,"fibers":0,"fluoride":null,"id":835,"iron":0.37,"long_description":"Chicken, broilers or fryers, breast, meat only, raw","magnesium":26,"manganese":0.015,"manufacturer_name":null,"monounsaturated_fat":0.763,"omega_3":null,"omega_6":null,"pg_search_rank":0.603124,"phosphorus":210,"polyunsaturated_fat":0.399,"potassium":370,"protein":21.23,"refuse_description":"20% bone, 9% skin, 6% separable fat","refuse_percentage":35,"saturated_fat":0.567,"scientific_name":null,"selenium":32,"short_description":"CHICKEN,BROILERS OR FRYERS,BREAST,MEAT ONLY,RAW","sodium":116,"source":"USDA","sugar":0,"textsearchable_col":"\'breast\':5,13 \'broiler\':2,10 \'chicken\':1,9 \'fryer\':4,12 \'meat\':6,14 \'raw\':8,16","trans_fat":0.012,"updated_at":"2013-02-02T21:01:31Z","vit_a":9,"vit_b1":0.064,"vit_b12":0.2,"vit_b2":0.1,"vit_b3":10.43,"vit_b5":1.425,"vit_b6":0.749,"vit_b7":null,"vit_b9":4,"vit_c":1.2,"vit_d":5,"vit_e":0.19,"vit_k":0.2,"water":75.79,"zinc":0.58},"unit":"g","amount":"150"},{"food":{"ala":null,"alcohol":0,"alpha_carotene":7,"beta_carotene":8509,"caffeine":0,"calcium":30,"carbohydrate":20.12,"category":"Vegetables and Vegetable Products","cholesterol":0,"common_name":"Sweetpotato, Includes USDA commodity food A230","copper":0.151,"created_at":"2013-02-02T21:02:50Z","density":null,"dha":0,"dpa":0,"energy":86,"epa":0,"fat":0.05,"fibers":3,"fluoride":null,"id":3191,"iron":0.61,"long_description":"Sweet potato, raw, unprepared","magnesium":25,"manganese":0.258,"manufacturer_name":null,"monounsaturated_fat":0.001,"omega_3":null,"omega_6":null,"pg_search_rank":0.756438,"phosphorus":47,"polyunsaturated_fat":0.014,"potassium":337,"protein":1.57,"refuse_description":"Parings and trimmings","refuse_percentage":28,"saturated_fat":0.018,"scientific_name":"Ipomoea batatas","selenium":0.6,"short_description":"SWEET POTATO,RAW,UNPREP","sodium":55,"source":"USDA","sugar":4.18,"textsearchable_col":"\'a230\':6 \'batata\':16 \'commod\':4 \'food\':5 \'includ\':2 \'ipomoea\':15 \'potato\':8,12 \'raw\':9,13 \'sweet\':7,11 \'sweetpotato\':1 \'unprep\':10 \'unprepar\':14 \'usda\':3","trans_fat":null,"updated_at":"2013-02-02T21:02:50Z","vit_a":709,"vit_b1":0.078,"vit_b12":0,"vit_b2":0.061,"vit_b3":0.557,"vit_b5":0.8,"vit_b6":0.209,"vit_b7":null,"vit_b9":11,"vit_c":2.4,"vit_d":0,"vit_e":0.26,"vit_k":1.8,"water":77.28,"zinc":0.3},"unit":"g","amount":"200"}],"amount":1}]');
    
    var menus = new Menus(defaultMenus);
    menus.each(function (menu) {
        menuItems = new MenuItems(menu.get('menuItems'));
        menuItems.menuCid = menu.cid;
        menuItems.each(function (menuItem) {
            menuItem.menuCid = menu.cid;
            menuItem.set('food', new Food(menuItem.get('food')));
        });
        menu.set('menuItems', menuItems);
    });
    
    var menuCount = 1 + menus.length;
    
    var MenuView = Backbone.View.extend({
        className: "menu",
  
        initialize: function() {
            this.listenTo(this.model, 'change', this.render);
            var menuItems = this.model.get('menuItems');
            this.menuItemsView = new MenuItemsView({
              collection: menuItems
            });
            this.search = new Search({});
            this.search.menuItems = menuItems;
        },
        
        render: function() {
            var html = _.template($('#menuTemplate').html(), {menu: this.model});
            this.$el.html(html);
            this.$(".menuItems").append(this.menuItemsView.render().$el);
            this.$("#search").append(this.search.render().$el);
            return this;
        },
      
        events: {
            "change .nameMenu": "nameChange",
            "change .amountMenu": "amountChange"
        },
        
        nameChange: function(e) {
            name = $(e.currentTarget).val();
            this.model.set("name", name);
        },
      
        amountChange: function(e) {
            amount = $(e.currentTarget).val();
            this.model.set("amount", amount);
        },
    });
    
    var MenusView = Backbone.View.extend({
        className: "menus",
        
        initialize: function() {
            this.listenTo(this.collection, 'add', this.render);
            this.listenTo(this.collection, 'remove', this.render);
            this.listenTo(this.collection, 'reset', this.render);
            this.listenTo(this.collection, 'sort', this.render);
        },
        
        render: function() {
            this.$el.html('');
            this.collection.each(this.renderOne, this);
            return this;
        },
        
        renderOne: function(model) {
            var menu = new MenuView({model:model, id:model.cid});
            this.$el.append(menu.render().$el);
            this.$el.append("<br />")
            return this;
        },
        
        events: {
          "click .deleteMenu": "deleteClicked"
        },
      
        deleteClicked: function(e) {
          e.preventDefault();
          itemCid = $(e.currentTarget).closest(".menu").attr('id');
          this.collection.remove(itemCid);
        }
    });
    
    var menusView = new MenusView({
        collection: menus,
        el: $(".menus")[0]
    });
    menusView.render();
    
    $("#newMenu").click(function(e) {
        menu = new Menu({name: "Menu " + menuCount, menuItems: new MenuItems()});
        menu.get('menuItems').menuCid = menu.cid;
        menus.add(menu);
        // menus.add({name: "Menu " + menuCount, menuItems: new MenuItems()});
        menuCount++;
    });
    
    var Goal = Backbone.Model.extend({});
    var Goals = Backbone.Collection.extend({
        model: Goal
    });
    
    var GoalView = Backbone.View.extend({
        className: "goal alter",
      
        initialize: function() {
            this.listenTo(this.model, 'change', this.render);
        },
        
        render: function() {
            var html = _.template($('#goalTemplate').html(), {goal: this.model});
            this.$el.html(html);
            return this;
        },
      
        events: {
            "click .goalNutrient": "nutrientChange",
            "change .goalValue": "valueChange"
        },
        
        nutrientChange: function(e) {
            e.preventDefault();
            nutrient = e.currentTarget.id;
            this.model.set("nutrient", nutrient);
        },
      
        valueChange: function(e) {
            value = $(e.currentTarget).val();
            this.model.set("value", value);
        },
    });
    
    var GoalsView = Backbone.View.extend({
        className: "goals",
        
        initialize: function() {
            this.listenTo(this.collection, 'add', this.render);
            this.listenTo(this.collection, 'remove', this.render);
            this.listenTo(this.collection, 'reset', this.render);
            this.listenTo(this.collection, 'sort', this.render);
        },
        
        render: function() {
            this.$el.html('');
            this.collection.each(this.renderOne, this);
            return this;
        },
        
        renderOne: function(model) {
            var menu = new GoalView({model:model, id:model.cid});
            this.$el.append(menu.render().$el);
            // this.$el.append("<br />")
            return this;
        },
        
        events: {
          "click .deleteGoal": "deleteClicked"
        },
      
        deleteClicked: function(e) {
          e.preventDefault();
          itemCid = $(e.currentTarget).closest(".goal").attr('id');
          this.collection.remove(itemCid);
        }
    });
    
    var defaultGoals = JSON.parse('[{"nutrient":"energy","value":"600"},{"nutrient":"protein","value":"35"},{"nutrient":"vit_a","value":"700"}]');
    var goals = new Goals(defaultGoals);
    
    var goalsView = new GoalsView({
        collection: goals,
        el: $(".goals")[0]
    });
    
    goalsView.render();
    
    $("#newGoal").click(function(e) {
        goals.add({});
    });
    
    // var pjs = Processing.getInstanceById("nutrisketch");
    
    var pjsController = {
        setPjs : function() {
            this.pjs = Processing.getInstanceById("nutrisketch");
        },
        
        initialize: function() {
            // this.listenTo(menus, 'add', this.addMenu);
            menus.on('add', this.addMenu, this);
            menus.on('remove', this.removeMenu, this);
            // this.listenTo(menus, 'reset', this.render);
            // this.listenTo(menus, 'sort', this.render);
            
            goals.on('add', this.addGoal, this);
            goals.on('remove', this.removeGoal, this);
            // this.listenTo(goals, 'reset', this.render);
            // this.listenTo(goals, 'sort', this.render);
            var that = this;
            menus.each(function (menu) {
                that.addMenu(menu, null, null);
                // menu.on('change', this.changeMenu, this);
            });
            goals.each(function (goal) {
                that.addGoal(goal, null, null);
                // goal.on('change', this.changeGoal, this);
            });
        },
        
        addMenu: function(menu, menus, options) {
            // var menu = e.model;
            var menuItems = menu.get('menuItems');
            menu.on('change', this.changeMenu, this)
            menuItems.on('add', this.addMenuItem, this);
            menuItems.on('remove', this.removeMenuItem, this);
            
            var name = menu.get('name');
            var amount = menu.get('amount');
            if (amount == null) {
                amount = 0;
            }
            pjsMenu = new this.pjs.Menu(menu.cid, name, amount);
            this.pjs.addMenu(pjsMenu);
            var that = this;
            menuItems.each(function(menuItem) {
                that.addMenuItem(menuItem, null, null);
            })
        },
        
        addGoal: function(goal, goals, options) {
            goal.on('change', this.changeGoal, this)
            
            pjsGoal = new this.pjs.Goal(goal.cid);
            var nutrient = goal.get('nutrient');
            var value = goal.get('value');
            if (value == null) {
                value = 0;
            }
            if (nutrient != null) {
                pjsGoal.unit = document.NUTRIENTS[nutrient].unit;
                pjsGoal.nutrientName = document.NUTRIENTS[nutrient].name.capitalize();
            }
            pjsGoal.change(nutrient, value);
            this.pjs.addGoal(pjsGoal);
        },
        
        removeMenu: function(menu, menus, options) {
            // var menu = e.model;
            this.pjs.removeMenu(menu.cid);
        },
        
        removeGoal: function(goal, goals, options) {
            // var goal = e.model;
            this.pjs.removeGoal(goal.cid);
        },
        
        changeMenu: function(menu, options) {
            // var menu = e.model;
            var name = menu.get('name');
            var amount = menu.get('amount');
            if (amount == null) {
                amount = 0;
            }
            
            pjsMenu = this.pjs.getMenus().get(menu.cid);
            pjsMenu.change(name, amount);
        },
        
        changeGoal: function(goal, options) {
            // var goal = e.model;
            var nutrient = goal.get('nutrient');
            var value = goal.get('value');
            if (value == null) {
                value = 0;
            }
            
            pjsGoal = this.pjs.getGoals().get(goal.cid);
            if (nutrient != null) {
                pjsGoal.unit = document.NUTRIENTS[nutrient].unit;
                pjsGoal.nutrientName = document.NUTRIENTS[nutrient].name.capitalize();
            }
            pjsGoal.change(nutrient, value);
        },
        
        addMenuItem: function(menuItem, menuItems, options) {
            // var menuItem = e.model;
            var food = menuItem.get('food');
            menuItem.on('change', this.changeMenuItem, this);
            
            var amount = menuItem.get('amount');
            if (amount == null) {
                amount = 0
            }
            pjsMenuItem = new this.pjs.Ingredient(menuItem.cid);
            pjsMenuItem.change(amount, menuItem.get('unit'));
            for (var foodAttr in food.attributes) {
                pjsMenuItem.food.put(foodAttr, food.attributes[foodAttr]);
            }
            pjsMenu = this.pjs.getMenus().get(menuItem.menuCid);
            pjsMenu.addIngredient(pjsMenuItem);
        },
        
        removeMenuItem: function(menuItem, menuItems, options) {
            // var menuItem = e.model;
            var menuCid = menuItem.menuCid;
            
            pjsMenu = this.pjs.getMenus().get(menuCid);
            pjsMenu.removeIngredient(menuItem.cid);
        },
        
        changeMenuItem: function(menuItem, options) {
            // var menuItem = e.model;
            var menuCid = menuItem.menuCid;
            
            pjsMenu = this.pjs.getMenus().get(menuCid);
            pjsMenuItem = pjsMenu.getIngredient(menuItem.cid);
            var amount = menuItem.get('amount');
            if (amount == null) {
                amount = 0
            }
            pjsMenuItem.change(amount, menuItem.get('unit'));
        }
    }
    
    tId = setInterval(function() {
        pjsController.setPjs();
        if (pjsController.pjs) {
            // setup processingJS parameters once it is loaded
            clearInterval(tId);
            console.log("pjs set");
            pjsController.initialize();
            // make the processing canvas responsive
            enquire.register("(max-width: 768px)", function() {
                pjsController.pjs.setCanvasWidth($(".container").width());
            });
            enquire.register("(min-width: 768px) and (max-width: 992px)", function() {
                pjsController.pjs.setCanvasWidth(750);
            });
            enquire.register("(min-width: 992px) and (max-width: 1200px)", function() {
                pjsController.pjs.setCanvasWidth(970);
            });
            enquire.register("(min-width: 1200px)", function() {
                pjsController.pjs.setCanvasWidth(1170);
            });
            $("body").css("padding-top", $("#navbar").height());
        }
      }, 500);
    
    $("#zoomIn").click(function(e) {
        pjsController.pjs.zoomIn();
        // setup the navbar
        $("body").css("padding-top", $("#navbar").height());
    });
    
    $("#zoomOut").click(function(e) {
        pjsController.pjs.zoomOut();
        // setup the navbar
        $("body").css("padding-top", $("#navbar").height());
    });
    
      
    $("#saveModels").click(function(e) {
        console.log(JSON.stringify(menus));
        console.log(JSON.stringify(goals));
    });
});