(function() {
  /*
  File generated by js-routes 1.2.1
  Based on Rails routes of Russ::Application
  */


  (function() {
    var NodeTypes, ParameterMissing, ReservedOptions, Utils, createGlobalJsRoutesObject, defaults, root,
      __hasProp = {}.hasOwnProperty,
      __slice = [].slice;

    root = typeof exports !== "undefined" && exports !== null ? exports : this;

    ParameterMissing = function(message) {
      this.message = message;
    };

    ParameterMissing.prototype = new Error();

    defaults = {
      prefix: "",
      default_url_options: {}
    };

    NodeTypes = {"GROUP":1,"CAT":2,"SYMBOL":3,"OR":4,"STAR":5,"LITERAL":6,"SLASH":7,"DOT":8};

    ReservedOptions = ['anchor', 'trailing_slash', 'host', 'port', 'protocol'];

    Utils = {
      default_serializer: function(object, prefix) {
        var element, i, key, prop, s, _i, _len;

        if (prefix == null) {
          prefix = null;
        }
        if (object == null) {
          return "";
        }
        if (!prefix && !(this.get_object_type(object) === "object")) {
          throw new Error("Url parameters should be a javascript hash");
        }
        s = [];
        switch (this.get_object_type(object)) {
          case "array":
            for (i = _i = 0, _len = object.length; _i < _len; i = ++_i) {
              element = object[i];
              s.push(this.default_serializer(element, prefix + "[]"));
            }
            break;
          case "object":
            for (key in object) {
              if (!__hasProp.call(object, key)) continue;
              prop = object[key];
              if ((prop == null) && (prefix != null)) {
                prop = "";
              }
              if (prop != null) {
                if (prefix != null) {
                  key = "" + prefix + "[" + key + "]";
                }
                s.push(this.default_serializer(prop, key));
              }
            }
            break;
          default:
            if (object != null) {
              s.push("" + (encodeURIComponent(prefix.toString())) + "=" + (encodeURIComponent(object.toString())));
            }
        }
        if (!s.length) {
          return "";
        }
        return s.join("&");
      },
      custom_serializer: null,
      serialize: function(object) {
        if ((this.custom_serializer != null) && this.get_object_type(this.custom_serializer) === "function") {
          return this.custom_serializer(object);
        } else {
          return this.default_serializer(object);
        }
      },
      clean_path: function(path) {
        var last_index;

        path = path.split("://");
        last_index = path.length - 1;
        path[last_index] = path[last_index].replace(/\/+/g, "/");
        return path.join("://");
      },
      extract_options: function(number_of_params, args) {
        var last_el;

        last_el = args[args.length - 1];
        if ((args.length > number_of_params && last_el === void 0) || ((last_el != null) && "object" === this.get_object_type(last_el) && !this.looks_like_serialized_model(last_el))) {
          return args.pop() || {};
        } else {
          return {};
        }
      },
      looks_like_serialized_model: function(object) {
        return "id" in object || "to_param" in object;
      },
      path_identifier: function(object) {
        var property;

        if (object === 0) {
          return "0";
        }
        if (!object) {
          return "";
        }
        property = object;
        if (this.get_object_type(object) === "object") {
          if ("to_param" in object) {
            property = object.to_param;
          } else if ("id" in object) {
            property = object.id;
          } else {
            property = object;
          }
          if (this.get_object_type(property) === "function") {
            property = property.call(object);
          }
        }
        return property.toString();
      },
      clone: function(obj) {
        var attr, copy, key;

        if ((obj == null) || "object" !== this.get_object_type(obj)) {
          return obj;
        }
        copy = obj.constructor();
        for (key in obj) {
          if (!__hasProp.call(obj, key)) continue;
          attr = obj[key];
          copy[key] = attr;
        }
        return copy;
      },
      merge: function() {
        var tap, xs;

        xs = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        tap = function(o, fn) {
          fn(o);
          return o;
        };
        if ((xs != null ? xs.length : void 0) > 0) {
          return tap({}, function(m) {
            var k, v, x, _i, _len, _results;

            _results = [];
            for (_i = 0, _len = xs.length; _i < _len; _i++) {
              x = xs[_i];
              _results.push((function() {
                var _results1;

                _results1 = [];
                for (k in x) {
                  v = x[k];
                  _results1.push(m[k] = v);
                }
                return _results1;
              })());
            }
            return _results;
          });
        }
      },
      normalize_options: function(url_defaults, required_parameters, optional_parts, actual_parameters) {
        var i, key, options, result, url_parameters, value, _i, _len;

        options = this.extract_options(required_parameters.length, actual_parameters);
        if (actual_parameters.length > required_parameters.length) {
          throw new Error("Too many parameters provided for path");
        }
        options = this.merge(defaults.default_url_options, url_defaults, options);
        result = {};
        url_parameters = {};
        result['url_parameters'] = url_parameters;
        for (key in options) {
          if (!__hasProp.call(options, key)) continue;
          value = options[key];
          if (ReservedOptions.indexOf(key) >= 0) {
            result[key] = value;
          } else {
            url_parameters[key] = value;
          }
        }
        for (i = _i = 0, _len = required_parameters.length; _i < _len; i = ++_i) {
          value = required_parameters[i];
          if (i < actual_parameters.length) {
            url_parameters[value] = actual_parameters[i];
          }
        }
        return result;
      },
      build_route: function(required_parameters, optional_parts, route, url_defaults, args) {
        var options, parameters, result, url, url_params;

        args = Array.prototype.slice.call(args);
        options = this.normalize_options(url_defaults, required_parameters, optional_parts, args);
        parameters = options['url_parameters'];
        result = "" + (this.get_prefix()) + (this.visit(route, parameters));
        url = Utils.clean_path("" + result);
        if (options['trailing_slash'] === true) {
          url = url.replace(/(.*?)[\/]?$/, "$1/");
        }
        if ((url_params = this.serialize(parameters)).length) {
          url += "?" + url_params;
        }
        url += options.anchor ? "#" + options.anchor : "";
        if (url_defaults) {
          url = this.route_url(options) + url;
        }
        return url;
      },
      visit: function(route, parameters, optional) {
        var left, left_part, right, right_part, type, value;

        if (optional == null) {
          optional = false;
        }
        type = route[0], left = route[1], right = route[2];
        switch (type) {
          case NodeTypes.GROUP:
            return this.visit(left, parameters, true);
          case NodeTypes.STAR:
            return this.visit_globbing(left, parameters, true);
          case NodeTypes.LITERAL:
          case NodeTypes.SLASH:
          case NodeTypes.DOT:
            return left;
          case NodeTypes.CAT:
            left_part = this.visit(left, parameters, optional);
            right_part = this.visit(right, parameters, optional);
            if (optional && (((left[0] === NodeTypes.SYMBOL || left[0] === NodeTypes.CAT) && !left_part) || ((right[0] === NodeTypes.SYMBOL || right[0] === NodeTypes.CAT) && !right_part))) {
              return "";
            }
            return "" + left_part + right_part;
          case NodeTypes.SYMBOL:
            value = parameters[left];
            if (value != null) {
              delete parameters[left];
              return this.path_identifier(value);
            }
            if (optional) {
              return "";
            } else {
              throw new ParameterMissing("Route parameter missing: " + left);
            }
            break;
          default:
            throw new Error("Unknown Rails node type");
        }
      },
      build_path_spec: function(route, wildcard) {
        var left, right, type;

        if (wildcard == null) {
          wildcard = false;
        }
        type = route[0], left = route[1], right = route[2];
        switch (type) {
          case NodeTypes.GROUP:
            return "(" + (this.build_path_spec(left)) + ")";
          case NodeTypes.CAT:
            return "" + (this.build_path_spec(left)) + (this.build_path_spec(right));
          case NodeTypes.STAR:
            return this.build_path_spec(left, true);
          case NodeTypes.SYMBOL:
            if (wildcard === true) {
              return "" + (left[0] === '*' ? '' : '*') + left;
            } else {
              return ":" + left;
            }
            break;
          case NodeTypes.SLASH:
          case NodeTypes.DOT:
          case NodeTypes.LITERAL:
            return left;
          default:
            throw new Error("Unknown Rails node type");
        }
      },
      visit_globbing: function(route, parameters, optional) {
        var left, right, type, value;

        type = route[0], left = route[1], right = route[2];
        if (left.replace(/^\*/i, "") !== left) {
          route[1] = left = left.replace(/^\*/i, "");
        }
        value = parameters[left];
        if (value == null) {
          return this.visit(route, parameters, optional);
        }
        parameters[left] = (function() {
          switch (this.get_object_type(value)) {
            case "array":
              return value.join("/");
            default:
              return value;
          }
        }).call(this);
        return this.visit(route, parameters, optional);
      },
      get_prefix: function() {
        var prefix;

        prefix = defaults.prefix;
        if (prefix !== "") {
          prefix = (prefix.match("/$") ? prefix : "" + prefix + "/");
        }
        return prefix;
      },
      route: function(required_parts, optional_parts, route_spec, url_defaults) {
        var path_fn;

        path_fn = function() {
          return Utils.build_route(required_parts, optional_parts, route_spec, url_defaults, arguments);
        };
        path_fn.required_params = required_parts;
        path_fn.toString = function() {
          return Utils.build_path_spec(route_spec);
        };
        return path_fn;
      },
      route_url: function(route_defaults) {
        var hostname, port, protocol;

        if (typeof route_defaults === 'string') {
          return route_defaults;
        }
        protocol = route_defaults.protocol || Utils.current_protocol();
        hostname = route_defaults.host || window.location.hostname;
        port = route_defaults.port || (!route_defaults.host ? Utils.current_port() : void 0);
        port = port ? ":" + port : '';
        return protocol + "://" + hostname + port;
      },
      has_location: function() {
        return typeof window !== 'undefined' && typeof window.location !== 'undefined';
      },
      current_host: function() {
        return this.has_location() && window.location.hostname;
      },
      current_protocol: function() {
        if (this.has_location() && window.location.protocol !== '') {
          return window.location.protocol.replace(/:$/, '');
        } else {
          return 'http';
        }
      },
      current_port: function() {
        if (this.has_location() && window.location.port !== '') {
          return window.location.port;
        } else {
          return '';
        }
      },
      _classToTypeCache: null,
      _classToType: function() {
        var name, _i, _len, _ref;

        if (this._classToTypeCache != null) {
          return this._classToTypeCache;
        }
        this._classToTypeCache = {};
        _ref = "Boolean Number String Function Array Date RegExp Object Error".split(" ");
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          name = _ref[_i];
          this._classToTypeCache["[object " + name + "]"] = name.toLowerCase();
        }
        return this._classToTypeCache;
      },
      get_object_type: function(obj) {
        if (root.jQuery && (root.jQuery.type != null)) {
          return root.jQuery.type(obj);
        }
        if (obj == null) {
          return "" + obj;
        }
        if (typeof obj === "object" || typeof obj === "function") {
          return this._classToType()[Object.prototype.toString.call(obj)] || "object";
        } else {
          return typeof obj;
        }
      }
    };

    createGlobalJsRoutesObject = function() {
      var namespace;

      namespace = function(mainRoot, namespaceString) {
        var current, parts;

        parts = (namespaceString ? namespaceString.split(".") : []);
        if (!parts.length) {
          return;
        }
        current = parts.shift();
        mainRoot[current] = mainRoot[current] || {};
        return namespace(mainRoot[current], parts.join("."));
      };
      namespace(root, "Routes");
      root.Routes = {
  // destroy_user_session => /users/sign_out(.:format)
    // function(options)
    destroyUserSessionPath: Utils.route([], ["format"], [2,[7,"/",false],[2,[6,"users",false],[2,[7,"/",false],[2,[6,"sign_out",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]),
  // edit_feed => /feeds/:id/edit(.:format)
    // function(id, options)
    editFeedPath: Utils.route(["id"], ["format"], [2,[7,"/",false],[2,[6,"feeds",false],[2,[7,"/",false],[2,[3,"id",false],[2,[7,"/",false],[2,[6,"edit",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]),
  // edit_item => /items/:id/edit(.:format)
    // function(id, options)
    editItemPath: Utils.route(["id"], ["format"], [2,[7,"/",false],[2,[6,"items",false],[2,[7,"/",false],[2,[3,"id",false],[2,[7,"/",false],[2,[6,"edit",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]),
  // edit_subscription => /subscriptions/:id/edit(.:format)
    // function(id, options)
    editSubscriptionPath: Utils.route(["id"], ["format"], [2,[7,"/",false],[2,[6,"subscriptions",false],[2,[7,"/",false],[2,[3,"id",false],[2,[7,"/",false],[2,[6,"edit",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]),
  // edit_tag => /tags/:id/edit(.:format)
    // function(id, options)
    editTagPath: Utils.route(["id"], ["format"], [2,[7,"/",false],[2,[6,"tags",false],[2,[7,"/",false],[2,[3,"id",false],[2,[7,"/",false],[2,[6,"edit",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]),
  // feed => /feeds/:id(.:format)
    // function(id, options)
    feedPath: Utils.route(["id"], ["format"], [2,[7,"/",false],[2,[6,"feeds",false],[2,[7,"/",false],[2,[3,"id",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]),
  // feeds => /feeds(.:format)
    // function(options)
    feedsPath: Utils.route([], ["format"], [2,[7,"/",false],[2,[6,"feeds",false],[1,[2,[8,".",false],[3,"format",false]],false]]]),
  // import_subscriptions => /subscriptions/import(.:format)
    // function(options)
    importSubscriptionsPath: Utils.route([], ["format"], [2,[7,"/",false],[2,[6,"subscriptions",false],[2,[7,"/",false],[2,[6,"import",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]),
  // item => /items/:id(.:format)
    // function(id, options)
    itemPath: Utils.route(["id"], ["format"], [2,[7,"/",false],[2,[6,"items",false],[2,[7,"/",false],[2,[3,"id",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]),
  // items => /items(.:format)
    // function(options)
    itemsPath: Utils.route([], ["format"], [2,[7,"/",false],[2,[6,"items",false],[1,[2,[8,".",false],[3,"format",false]],false]]]),
  // new_feed => /feeds/new(.:format)
    // function(options)
    newFeedPath: Utils.route([], ["format"], [2,[7,"/",false],[2,[6,"feeds",false],[2,[7,"/",false],[2,[6,"new",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]),
  // new_item => /items/new(.:format)
    // function(options)
    newItemPath: Utils.route([], ["format"], [2,[7,"/",false],[2,[6,"items",false],[2,[7,"/",false],[2,[6,"new",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]),
  // new_subscription => /subscriptions/new(.:format)
    // function(options)
    newSubscriptionPath: Utils.route([], ["format"], [2,[7,"/",false],[2,[6,"subscriptions",false],[2,[7,"/",false],[2,[6,"new",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]),
  // new_tag => /tags/new(.:format)
    // function(options)
    newTagPath: Utils.route([], ["format"], [2,[7,"/",false],[2,[6,"tags",false],[2,[7,"/",false],[2,[6,"new",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]),
  // new_user_session => /users/sign_in(.:format)
    // function(options)
    newUserSessionPath: Utils.route([], ["format"], [2,[7,"/",false],[2,[6,"users",false],[2,[7,"/",false],[2,[6,"sign_in",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]),
  // rails_info => /rails/info(.:format)
    // function(options)
    railsInfoPath: Utils.route([], ["format"], [2,[7,"/",false],[2,[6,"rails",false],[2,[7,"/",false],[2,[6,"info",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]),
  // rails_info_properties => /rails/info/properties(.:format)
    // function(options)
    railsInfoPropertiesPath: Utils.route([], ["format"], [2,[7,"/",false],[2,[6,"rails",false],[2,[7,"/",false],[2,[6,"info",false],[2,[7,"/",false],[2,[6,"properties",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]),
  // rails_info_routes => /rails/info/routes(.:format)
    // function(options)
    railsInfoRoutesPath: Utils.route([], ["format"], [2,[7,"/",false],[2,[6,"rails",false],[2,[7,"/",false],[2,[6,"info",false],[2,[7,"/",false],[2,[6,"routes",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]]]),
  // rails_mailers => /rails/mailers(.:format)
    // function(options)
    railsMailersPath: Utils.route([], ["format"], [2,[7,"/",false],[2,[6,"rails",false],[2,[7,"/",false],[2,[6,"mailers",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]),
  // root => /
    // function(options)
    rootPath: Utils.route([], [], [7,"/",false]),
  // subscription => /subscriptions/:id(.:format)
    // function(id, options)
    subscriptionPath: Utils.route(["id"], ["format"], [2,[7,"/",false],[2,[6,"subscriptions",false],[2,[7,"/",false],[2,[3,"id",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]),
  // subscriptions => /subscriptions(.:format)
    // function(options)
    subscriptionsPath: Utils.route([], ["format"], [2,[7,"/",false],[2,[6,"subscriptions",false],[1,[2,[8,".",false],[3,"format",false]],false]]]),
  // tag => /tags/:id(.:format)
    // function(id, options)
    tagPath: Utils.route(["id"], ["format"], [2,[7,"/",false],[2,[6,"tags",false],[2,[7,"/",false],[2,[3,"id",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]),
  // tags => /tags(.:format)
    // function(options)
    tagsPath: Utils.route([], ["format"], [2,[7,"/",false],[2,[6,"tags",false],[1,[2,[8,".",false],[3,"format",false]],false]]]),
  // update_all_subscriptions => /subscriptions/update_all(.:format)
    // function(options)
    updateAllSubscriptionsPath: Utils.route([], ["format"], [2,[7,"/",false],[2,[6,"subscriptions",false],[2,[7,"/",false],[2,[6,"update_all",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]),
  // upload_subscriptions => /subscriptions/upload(.:format)
    // function(options)
    uploadSubscriptionsPath: Utils.route([], ["format"], [2,[7,"/",false],[2,[6,"subscriptions",false],[2,[7,"/",false],[2,[6,"upload",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]]),
  // user_session => /users/sign_in(.:format)
    // function(options)
    userSessionPath: Utils.route([], ["format"], [2,[7,"/",false],[2,[6,"users",false],[2,[7,"/",false],[2,[6,"sign_in",false],[1,[2,[8,".",false],[3,"format",false]],false]]]]])}
  ;
      root.Routes.options = defaults;
      root.Routes.default_serializer = function(object, prefix) {
        return Utils.default_serializer(object, prefix);
      };
      return root.Routes;
    };

    if (typeof define === "function" && define.amd) {
      define([], function() {
        return createGlobalJsRoutesObject();
      });
    } else {
      createGlobalJsRoutesObject();
    }

  }).call(this);

}).call(module.exports);
