module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    banner: '/*!\n' +
            ' * <%= pkg.name %> v<%= pkg.version %> (<%= pkg.homepage %>)\n' +
            ' * Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>\n' +
            ' * Licensed under <%= pkg.license %> (<%= pkg.homepage %>/blob/master/LICENSE)\n' +
            ' */\n',

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
    pdf: (function () {
      var obj = {
          tp: {
            input: 'public_html/tournament-pack/index.html',
            output: 'tournament-pack'
          }
        };

      grunt.file.recurse('public_html/army-lists', function(abspath, rootdir, subdir, filename) {
        filename = filename.replace(/\.html$/, '');

        obj[filename] = {
          input: abspath,
          output: filename
        };
      });

      return obj;
    }()),
    shell: {
      options: {
        stderr: false
      },
      build: { command: 'jekyll build' },
      prince: { command: 'prince --script=public_html/js/tp-print.min.js --style=public_html/css/tp-print.min.css -o public_html/pdfs/netea-<%= grunt.config("output") %>.pdf <%= grunt.config("input") %>' },
      remove_prince_annot: { command: 'sed -i "0,/\\/Annots /{s~/Annots \\[\\([0-9]\\+ 0 R \\)\\{2\\}~/Annots [~}" public_html/pdfs/netea-<%= grunt.config("output") %>.pdf' }
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

  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-shell');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-watch');

  grunt.registerTask('default', ['shell:build', 'less', 'uglify', 'pdf']);

  grunt.registerMultiTask('pdf', function () {
    grunt.file.mkdir('public_html/pdfs');

    grunt.config('input', this.data.input);
    grunt.config('output', this.data.output);

    grunt.task.run([
      'shell:prince',
      'shell:remove_prince_annot'
    ]);
  });
};