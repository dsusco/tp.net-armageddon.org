(function () {
  'use strict';

  var
    cheerio = require('cheerio'),
    moment = require('moment'),
    yaml = require('js-yaml');

  module.exports = function (grunt) {
    var
      writeDoc = function (file, template, obj) {
        if (!grunt.file.exists(file) ||
            !moment(yaml.safeLoad(grunt.file.read(file).match(/---\n((.|\n)*)\n---/m)[1]).date).isSame(moment(obj.date))) {
          console.log('Writing to ' + file);

          grunt.file.write(file, grunt.template.process(template, { data: obj }));
        }
      },
      getIdArray = function (str, sort) {
        try {
          var idArray = str.match(/\[[a-z][\w\-]*\]/g).map(function (id) {
            return id.match(/[\w\-]+/g)[0];
          });

          return sort ? idArray.sort() : idArray;
        } catch (error) {
          return null;
        }
      };

    grunt.initConfig({
      pkg: grunt.file.readJSON('package.json'),
      banner: '/*!\n' +
              ' * <%= pkg.name %> v<%= pkg.version %> (<%= pkg.homepage %>)\n' +
              ' * Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>\n' +
              ' * Licensed under <%= pkg.license %> (<%= pkg.homepage %>/blob/master/LICENSE)\n' +
              ' */\n',

      clean: {
        fontconfig: ['fontconfig']
      },
      less: {
        print: {
          files: {
            'public_html/css/tp-print.min.css': '_site/_less/tp-print.less'
          },
          options: {
            banner: '<%= banner %>',
            compress: true,
            strictMath: true,
            strictUnits: true
          }
        },
        screen: {
          files: {
            'public_html/css/tp.min.css': '_site/_less/tp-screen.less'
          },
          options: {
            banner: '<%= banner %>',
            compress: true,
            strictMath: true,
            strictUnits: true
          }
        }
      },
      http: {
        special_rules: {
          options: {
            url: 'http://miniwars.co.uk/netea-json/special_rules',
            callback: function (error, response, body) {
              var template = grunt.file.read('grunt-templates/special_rule.md');

              JSON.parse(body).forEach(function (sr) {
                if (sr.netea_rule_url !== '') {
                  writeDoc(
                    '_site/_special_rules/' + sr.netea_rule_url + '.md',
                    template,
                    {
                      date: moment(sr.edit_date).format(),

                      name: sr.title,
                      abbr: sr.rule_abbreviation,

                      content: sr.special_rule_details
                    }
                  );
                }
              });
            }
          }
        },
        units: {
          options: {
            url: 'http://miniwars.co.uk/netea-json/units',
            callback: function (error, response, body) {
              var template = grunt.file.read('grunt-templates/unit.md');

              JSON.parse(body).forEach(function (u) {
                if (u.netea_unit_url !== '') {
                  writeDoc(
                    '_site/_units/' + u.netea_unit_url + '.md',
                    template,
                    {
                      date: moment(u.edit_date).format(),

                      name: u.title,
                      type: u.miniatures_netea[0].netea_type,
                      speed: u.miniatures_netea[0].netea_speed,
                      armour: u.miniatures_netea[0].netea_armour,
                      cc: u.miniatures_netea[0].netea_cc,
                      ff: u.miniatures_netea[0].netea_ff,

                      weapons: u.netea_weapons.map(function (w) {
                        return {
                          id: getIdArray(w.netea_weapon_weapon),
                          multiplier: w.netea_weapon_multiplier,
                          arc: w.netea_weapon_arc
                        };
                      }),

                      special_rules: getIdArray(u.miniatures_netea[0].netea_attributes, true),
                      notes: u.miniatures_netea[0].netea_notes.replace(/[\r\n]/g, ' ')// remove replace
                    }
                  );
                }
              });
            }
          }
        },
        weapons: {
          options: {
            url: 'http://miniwars.co.uk/netea-json/weapons',
            callback: function (error, response, body) {
              var template = grunt.file.read('grunt-templates/weapon.md');

              JSON.parse(body).forEach(function (w) {
                if (w.netea_weapons_url !== '') {
                  writeDoc(
                    '_site/_weapons/' + w.netea_weapons_url + '.md',
                    template,
                    {
                      date: moment(w.edit_date).format(),

                      name: w.title,
                      modes: w.weapon_details.map(function (m) {
                        return {
                          boolean: m.weapon_boolean,
                          range: m.weapon_range,
                          firepower: m.weapon_firepower,
                          special_rules: getIdArray(m.weapon_abilities, true)
                        };
                      })
                    }
                  );
                }
              });
            }
          }
        }
      },
      pdf: (function () {
        var obj = {
            'tournament-pack': {
              input: 'public_html/tournament-pack/index.html',
              output: 'tournament-pack'
            }
          };

        grunt.file.mkdir('public_html/army-lists');

        grunt.file.recurse('public_html/army-lists', function (abspath, rootdir, subdir, filename) {
          filename = filename.replace(/\.html$/, '');

          obj[filename] = {
            input: abspath,
            output: filename
          };
        });

        return obj;
      }()),
      shell: {
        options: { stderr: false },

        jekyll: { command: 'jekyll build' },
        prince: {
          command: [
            'prince --script=public_html/js/tp-print.min.js --style=public_html/css/tp-print.min.css -o public_html/pdfs/netea-<%= grunt.config("output-date") %>.pdf <%= grunt.config("input") %>',
            'sed -i "0,/\\/Annots /{s~/Annots \\[\\([0-9]\\+ 0 R \\)\\{2\\}~/Annots [~}" public_html/pdfs/netea-<%= grunt.config("output-date") %>.pdf'
          ].join('&&')
        }
      },
      uglify: {
        options: {
          banner: '<%= banner %>',
          mangle: false
        },
        print: {
          files: { 'public_html/js/tp-print.min.js': [
            'bower_components/jquery/dist/jquery.js',
            '_site/_js/tp.js'
          ]}
        },
        screen: {
          files: { 'public_html/js/tp.min.js': [
            'bower_components/jquery/dist/jquery.js',
            '_site/_js/delayed-resize.js',
            '_site/_js/delayed-scroll.js',
            '_site/_js/tp.js',
            '_site/_js/tp-screen.js'
          ]}
        }
      },
      watch: {
        less: {
          files: ['_site/_less/**/*.less'],
          tasks: ['less']
        },
        html: {
          files: ['public_html/index.html'],
          tasks: ['less', 'uglify']
        },
        uglify: {
          files: ['_site/_js/**/*.js'],
          tasks: ['uglify']
        }
      }
    });

    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-contrib-less');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-http');
    grunt.loadNpmTasks('grunt-shell');

    grunt.registerTask('default', ['shell:jekyll', 'less', 'uglify', 'pdf', 'clean:fontconfig']);

    grunt.registerMultiTask('pdf', function () {
      grunt.file.mkdir('public_html/pdfs');

      grunt.config('date', cheerio.load(grunt.file.read(this.data.input))('#date').text());
      grunt.config('input', this.data.input);
      grunt.config('output', this.data.output);
      grunt.config('output-date', grunt.config('output') + '-' + grunt.config('date'));

      grunt.task.run(['shell:prince']);

      grunt.file.write(
        'public_html/.htaccess',
        grunt.file.read('public_html/.htaccess').replace(
          new RegExp(grunt.config('output') + '-[^.]*'),
          grunt.config('output-date')
        )
      );
    });
  };
}());