
# DRY CRUD

[<img src="https://secure.travis-ci.org/codez/dry_crud.png"
/>](http://travis-ci.org/codez/dry_crud)

dry_crud generates simple and extendable controllers, views and helpers that
support you to DRY up the CRUD code in your Rails projects. List, search,
sort, show, create, edit and destroy any model entries in just 5 minutes.
Start with these artifacts and build a clean base to efficiently develop your
application upon.

##Table of Contents

- [Installation](#installation)
- [Integration](#integration)
- [Background](#background)
- [Examples](#examples)
  - [Controller with CRUD functionality](#controller-with-crud-functionality)
    - [Customize single views](#customize-single-views)
    - [Adapt general behavior](#adapt-general-behavior)
    - [Special formatting for selected attributes](#special-formatting-for-selected-attributes)
    - [Sorting and filtering the index list](#sorting-and-filtering-the-index-list)
  - [Standard Tables and Forms](#standard-tables-and-forms)
    - [Tables](#tables)
    - [Forms](#forms)
  - [Nested Resources](#nested-resources)
  - [CRUD controller callbacks](#crud-controller-callbacks)
  - [Internationalization (I18N)](#internationalization-i18n)
  - [Example Code](#example-code)
- [Generated Files](#generated-files)
  - [Controller](#controller)
  - [Helpers](#helpers)
  - [Views](#views)
    - [List](#list)
    - [Crud](#crud)
    - [Various](#various)
  - [Tests](#tests)
  - [Specs](#specs)

## Installation

Create your Rails application directly with the dry_crud application template:

    rails new APP_NAME -m https://raw.github.com/codez/dry_crud/master/template.rb

If your application already exists or you prefer the DIY way, then install the
Gem (`gem install dry_crud`), add it to your Gemfile and run the generator.
You may remove the Gemfile entry again afterwards, it is not required anymore.

    rails generate dry_crud [--templates haml] [--tests rspec]

By default, dry_crud generates ERB templates and Test::Unit tests. Pass the
options above to generate HAML templates and/or RSpec examples instead.

We recommend to use dry_crud as a generator as described above for the best
understanding and the most flexibility. When you are familiar with dry_crud,
it is now also possible to use it directly as a Rails Engine. Simply add the
gem to your Gemfile. You may still generate single files to adapt them:

    rails generate dry_crud:file list/index.html.erb

If a dry_crud file exists in your application, it will be used, if not, the
one from the engine is used. This holds for controllers, helpers and view
templates.

## Integration

To integrate dry_crud into your code, only a few additions are required:

*   For uniform CRUD functionality, just subclass your controllers from
    CrudController and define the `permitted_attrs` (for StrongParameters).

*   Overwrite the `to_s` method of your models for a human-friendly
    representation in captions.

*   Optionally define a `list` scope in your models to be used in the `index`
    action.

*   Optionally define a `options_list` scope in your models to be used in
    select dropdowns.


Version 2.0 and higher are compatible with Rails 4 and Rails 3.2. dry_crud is
tested with Ruby 1.9.3, 2.0.0 and JRuby. If you are using Ruby 1.8.7, please
refer to version 1.7.0.

## Background

In most Rails applications, you have some models that require basic CRUD
(create, read, update, delete) functionality. There are various possibilities
like Rails scaffolding, [Inherited
Resources](https://github.com/josevalim/inherited_resources) or [Rails
Admin](https://github.com/sferik/rails_admin). Still, various parts in your
application remain duplicated. While you might pull up common methods into a
common superclass controller, most views still contain very similar code. And
then you also have to remember the entire API of these frameworks.

Enter dry_crud.

**The main idea of dry_crud is to concentrate basic functionality of your
application, like CRUD actions, uniform formatting, forms and tables into
specifically extendable units. dry_crud generates various foundation classes
that you may browse easily and adapt freely to your application's needs. For
each model, you may transparently customize arbitrary parts or just fallback
to the general behavior. This applies not only for controllers, but also for
view templates and helpers. There is no black box your code depends on. You
lay the foundation that fits your application best.**

dry_crud is a Rails generator. All code resides in your application and is
open for you to inspect and to extend. You may pick whatever you consider
useful or adapt what is not sufficient. Even if you do not require any CRUD
functionality, you might find some helpers simplifying your work. There are no
runtime dependencies to the dry_crud gem. Having said this, dry_crud does not
want to provide a maximum of functionality that requires a lot of
configuration, but rather a clean and lightweight foundation to build your
application's requirements upon. This is why dry_crud comes as a generator and
not as a Rails plugin.

dry_crud does not depend on any other plugins, but easily allows you to
integrate them in order to unify the behavior of your CRUD controllers. You
might even use the plugins mentioned above to adapt your generated
CrudController base class. All classes come with thorough tests that provide
you with a solid foundation for implementing your own adaptions.

A basic CSS gets you started with your application's layout. For advanced
needs, dry_crud supports the styles and classes used in [Bootstrap
3](http://getbootstrap.com). A great design never was so close.

If you find yourself adapting the same parts of dry_crud for your applications
over and over, please feel free to [fork me on
Github](http://github.com/codez/dry_crud).

See the Examples section for some use cases and the Generated Files section
below for details on the single classes and templates.

## Examples

### Controller with CRUD functionality

Say you want to manage a `Person` model. Overwrite the `to_s` method of your
model for a human-friendly representation used in page titles.

`app/models/person.rb`:

```
class Person
  def to_s
    "#{lastname} #{firstname}"
  end
end
```

Then create the following controller. The `permitted_attrs` define the
attribute parameters allowed when creating or updating a model entry (see
[Strong
Paramters](http://api.rubyonrails.org/classes/ActionController/StrongParameter
s.html)).

`app/controllers/people_controller.rb`:
```
 class PeopleController < CrudController
   self.permitted_attrs = [:firstname, :lastname, :birthday, :sex, :city_id]
 end
```

That's it. You have a sortable overview of all people, detail pages and forms
to edit and create people. Of course, you may delete people as well. By
default, all attributes are displayed and formatted according to their column
type wherever they appear. This applies for the input fields as well.

#### Customize single views

Well, maybe there are certain attributes you do not want to display in the
people list, or others that are not editable in the form. No problem, simply
create a ` _list` partial in `app/views/people/_list.html.erb` to customize
this:

    <%= crud_table :lastname, :firstname, :city, :sex %>

This only displays these three attributes in the table. All other templates,
as well as the main index view, fallback to the ones in `app/views/crud`.

#### Adapt general behavior

Next, let's adapt a part of the general behavior used in all CRUD controllers.
As an example, we include pagination with
[kaminari](https://github.com/amatsuda/kaminari) in all our overview tables:

In `app/controllers/list_controller.rb`, change the list_entries method to
```
def list_entries
  model_scope.page(params[:page])
end
```

In `app/views/list/index.html.erb`, add the following line for the pagination
links:

    <%= paginate entries %>

And we are done. All our controllers inheriting from ListController, including
above `PeopleController`, now have paginated index views. Because our
customization for the people table is in the separate `_list` partial, no
further modifications are required.

#### Special formatting for selected attributes

Sometimes, the default formatting provided by `format_attr` will not be
sufficient. We have a boolean column `sex` in our model, but would like to
display 'male' or 'female' for it (instead of 'no' or 'yes', which is a bit
cryptic). Just define a method in your view helper starting with `format_`,
followed by the class and attribute name:

In `app/helpers/people.rb`:

```
 def format_person_sex(person)
   person.sex ? 'female' : 'male'
 end
```

Should you have attributes with the same name for multiple models that you
want to be formatted the same way, you may define a helper method
`format_{attr}` for these attributes.

By the way: The method `f` in FormatHelper uniformly formats arbitrary values
according to their class.

#### Sorting and filtering the index list

The entries listed on the index page are automatically sortable by each
displayed database column. To apply a default sorting order, define a `list`
scope in your model:

In `app/models/person.rb`:

    scope :list, -> { order('lastname, firstname').includes(:city) }

Alternatively, set the following class attribute in the controller:

In `app/controllers/people_controller.rb`:

    self.default_sort = 'lastname, firstname'

When you display computed values in your list table, you may define sort
mappings to enable sorting of these columns:

In `app/controllers/people_controller.rb`:

    self.sort_mappings = {age: 'birthday', city_id: 'cities.name'}

There is also a simple search functionality (based on SQL LIKE queries)
implemented in Crud::Searchable. Define an array of columns in your
controller's `search_columns` class variable to make the entries searchable by
these fields:

In `app/controllers/people_controller.rb`:

    self.search_columns = [:firstname, :lastname]

If you have search columns defined, a search box will be displayed in the
index view that enables filtering of the displayed entries.

### Standard Tables and Forms

dry_crud provides two builder classes for update/create forms and tables for
displaying entries of one model. They may be used all over your application to
DRY up the form and table code. Normally, they are used with the corresponding
methods from TableHelper and FormHelper. In there are generic helper methods
(`plain_table` and `plain_form`/`standard_form`) and slightly enhanced ones
for views of subclasses of CrudController (`crud_table` and `crud_form`).

#### Tables

The following code defines a table with some attribute columns for a list of
same-type entries. Columns get a header corresponding to the attribute name:

```
<%= plain_table(@people) do |t|
      t.sortable_attrs :lastname, :firstname
end %>
```

If entries is empty, a basic 'No entries found' message is rendered instead of
the table.

To render custom columns, use the `col` method with an appropriate block:

```
<%= plain_table(@people) do |t|
      t.sortable_attrs :lastname, :firstname
      t.col('', class: 'center') {|entry| image_tag(entry.picture) }
      t.attr :street
      t.col('Map') {|entry| link_to(entry.city, "http://maps.google.com/?q=#{entry.city}" }
    end %>
```

For views of subclasses of ListController, you can directly use the
`crud_table` helper method, where you do not have to pass the `@people` list
explicitly and actions are added automatically.

#### Forms

Forms work very similar. In the most simple case, you just have to specify
which attributes of a model to create input fields for, and you get a complete
form with error messages, labeled input fields according the column types and
a save button:

    <%= standard_form(@person, :firstname, :lastname, :age, :city) %>

Of course, custom input fields may be defined as well:

```
<%= standard_form(@person, url: custom_update_person_path(@person.id)) do |f| %>
  <%= f.labeled_input_fields :firstname, :lastname %>
  <%= f.labeled(:sex) do %>
    <%= f.radio_button :sex, true %> female
    <%= f.radio_button :sex, false %> male
  <% end %>
  <%= f.labeled_integer_field :age %>
  <%= f.labeled_file_field :picture %>
<% end %>
```

Even `belongs_to` associations are automatically rendered with a select field.
By default, entries returned from the `options_list` scope of the associated
model are used as options (if defined, all otherwise). To customize this,
either define an instance variable with the same name as the association in
your controller, or pass a `list` option:

    <%= f.belongs_to_field :hometown, list: City.where(country: @person.country) %>

Yes, it's bad practice to use finder logic in your views! Define the variable
`@hometowns` in your controller instead (as shown in the example above), and
you do not even have to specify the `list` option.

Optionally, `has_and_belongs_to_many` and `has_many` associations can be
rendered with a multi-select field. Similar to a `belongs_to` association, all
entries from the associated model are used, but can be overwritten using the
`list` option:

    <%= f.has_many_field :visited_cities, list: City.where(is_touristic: true) %>

And yes again, the same advice for where to put finder logic applies here as
well.

**Note:** `has_and_belongs_to_many` and `has_many` associations are not
automatically rendered in a form, you have to explicitly include these
attributes. You might also want to stylize the multi-select widget, for
example with a [jQuery UI
Multiselect](http://www.quasipartikel.at/multiselect/).

### Nested Resources

In case you define nested resources, your CrudController subclass should know.
Listing and creating entries as well as displaying links for these resources
is dependent on the nesting hierarchy. This is how you declare the namespaces
and parent resources in your controller:

    self.nesting = :my_namspace, ParentResource

This declaration is for a controller nested in `parent_resources` within a
`:my_namespace` scope. `ParentResource` is the corresponding `ActiveRecord`
model. The request param `:parent_resource_id` is used to load the parent
entry, which in turn is used to filter the entries listed and created in your
controller. For all parent resources, a corresponding instance variable is
created.

The `Crud::Nestable` module defines this basic behaviour. For more complex
setups, have a look there and adjust it to your needs.

### CRUD controller callbacks

As a last example, let's say we have added a custom input field that must
specially processed. Instead of overwriting the entire update action, it is
possible to register callbacks for the `create`, `update`, `save` (= `create`
and `update`) and `destroy` actions. They work very similarliy like the
callbacks on ActiveRecord. For each action, before and after callbacks are
run. Before callbacks may also prevent the action from being executed when
returning false. Here is some code:

In `app/controllers/people_controller.rb`:

```
after_save :upload_picture
before_destroy :delete_picture

def upload_picture
  store_file(params[:person][:picture]) if params[:person][:picture]
end

def delete_picture
  if !perform_delete_picture(entry.picture)
    flash.alert = 'Could not delete picture'
    false
  end
end
```

Beside these "action" callbacks, there is also a set of `before_render`
callbacks that are called whenever a certain view is rendered. They are
available for the `index`, `show`, `new`, `edit` and `form` (= `new` and
`edit`) views. These callbacks are not only called for the corresponding
action, but, for example, also when the `new` view is going to be rendered
from an unsuccessfull `create` action. Say you need to prepare additional
variables whenever the form is rendered:

In `app/controllers/people_controller.rb`:

```
before_render_form :set_hometowns

def set_hometowns
  @hometowns = City.where(country: entry.country)
end
```

### Internationalization (I18N)

All text strings used are externalized to an english locale yaml. The keys are
organized by controller and template name plus a generic global scope.

To represent your controller hierarchy, a special translation helper `ti`
looks up keys along the hierarchy in the following order:

```
{controller_name}.{template_name}.{key}
{controller_name}.{action_name}.{key}
{controller_name}.global.{key}
{parent_controller_name}.{template_name}.{key}
{parent_controller_name}.{action_name}.{key}
{parent_controller_name}.global.{key}
...
global.{key}
```

In order to change the title for your `PeopleController`'s `index` action, you
do not need to override the entire template, but simply define the following
key:

    people.index.title = "The People"

Otherwise, the lookup for the title would fallback on the ListController's key
`list.index.title`.

This lookup mechanism also allows you to easily define per-controller
overridable text snippets in your views.

### Example Code

To see an example application built on dry_crud, have a look at [these
directories](https://github.com/codez/dry_crud/tree/master/test/templates/app)
. Only certain methods and templates are overriden, all the 'missing' files
are provided by dry_crud.

## Generated Files

All generated files are supposed to provide a reasonable foundation for the
CRUD functionality. You are encouraged to adapt them to fit the needs of your
application. They're yours!

### Controller
<dl>
<dt>
<a href="http://codez.ch/dry_crud?q=CrudController">controller/crud_controller.rb</a>
</dt>
<dd>
Abstract controller providing basic CRUD actions. This implementation
mainly follows the one of the Rails scaffolding controller and responses
to HTML and JSON requests. Some enhancements were made to ease
extendability. Several protected helper methods are there to be
(optionally) overriden by subclasses. With the help of additional
callbacks, it is possible to hook into the action procedures without
overriding the entire method. This class is based on ListController.
</dd>

<dt><a href="http://codez.ch/dry_crud?q=ListController">controller/list_controller.rb</a></dt>
<dd>Abstract controller providing a basic list action. Use this controller if
you require read-only functionality. It includes the following modules.</dd>

<dt><a href="http://codez.ch/dry_crud?q=DryCrud::GenericModel">controller/dry_crud/generic_model.rb</a></dt>
<dd>Work with the model whose name corrsponds to the controller's name.</dd>

<dt><a href="http://codez.ch/dry_crud?q=DryCrud::Nestable">controller/dry_crud/nestable.rb</a></dt>
<dd>Provides functionality to easily nest controllers/resources.</dd>

<dt><a href="http://codez.ch/dry_crud?q=DryCrud::Rememberable">controller/dry_crud/rememberable.rb</a></dt>
<dd>Remembers certain params of the index action in order to return to the
same list after an entry was viewed or edited.</dd>

<dt><a href="http://codez.ch/dry_crud?q=DryCrud::Searchable">controller/dry_crud/searchable.rb</a></dt>
<dd>Search functionality for the index table.</dd>

<dt><a href="http://codez.ch/dry_crud?q=DryCrud::Sortable">controller/dry_crud/sortable.rb</a></dt>
<dd>Sort functionality for the index table.</dd>

<dt><a href="http://codez.ch/dry_crud?q=DryCrud::RenderCallbacks">controller/dry_crud/render_callbacks.rb</a></dt>
<dd>Provide <tt>before_render</tt> callbacks to controllers.</dd>

<dt><a href="http://codez.ch/dry_crud?q=DryCrud::Responder">controller/dry_crud/responder.rb</a></dt>
<dd>Responder used by the CrudController to handle the <tt>path_args</tt>.</dd>
</dl>

### Helpers
<dl>
<dt><a href="http://codez.ch/dry_crud?q=DryCrud::Form::Builder">helpers/dry_crud/form/builder.rb</a></dt>
<dd>A form builder that automatically selects the corresponding input type for
ActiveRecord columns. Input elements are rendered together with a label by
default.</dd>


<dt><a href="http://codez.ch/dry_crud?q=DryCrud::Form::Control">helpers/dry_crud/form/control.rb</a></dt>
<dd>Representation of a single form control consisting of a label, input
field, addon or help text.</dd>

<dt><a href="http://codez.ch/dry_crud?q=DryCrud::Table::Builder">helpers/dry_crud/table/builder.rb</a></dt>
<dd>A helper object to easily define tables listing several rows of the same
data type.</dd>

<dt><a href="http://codez.ch/dry_crud?q=DryCrud::Table::Col">helpers/dry_crud/table/col.rb</a></dt>
<dd>Helper class representing a single table column.</dd>

<dt><a href="http://codez.ch/dry_crud?q=DryCrud::Table::Actions">helpers/dry_crud/table/actions.rb</a></dt>
Module to add support for uniform CRUD actions in tables.

<dt><a href="http://codez.ch/dry_crud?q=DryCrud::Table::Sorting">helpers/dry_crud/table/sorting.rb</a></dt>
<dd>Module to add support for sort links in table headers.</dd>

<dt><a href="http://codez.ch/dry_crud?q=FormHelper">helpers/form_helper.rb</a></dt>
<dd>Create forms to edit models with Crud::FormBuilder. Contains a
standardized and a custom definable form.</dd>

<dt><a href="http://codez.ch/dry_crud?q=TableHelper">helpers/table_helper.rb</a></dt>
<dd>Create tables to list multiple models with Crud::TableBuilder. Contains a
standardized and a custom definable table.</dd>

<dt><a href="http://codez.ch/dry_crud?q=FormatHelper">helpers/format_helper.rb</a></dt>
<dd>Format attribute and basic values according to their database or Ruby type.</dd>

<dt><a href="http://codez.ch/dry_crud?q=ActionsHelper">helpers/actions_helper.rb</a></dt>
<dd>Uniform action links for the most common crud actions.</dd>

<dt><a href="http://codez.ch/dry_crud?q=I18nHelper">helpers/i18n_helper.rb</a></dt>
<dd>Translation helpers extending Rails' `translate` helper to support
translation inheritance over the controller class hierarchy.</dd>

<dt><a href="http://codez.ch/dry_crud?q=UtilityHelper">helpers/utility_helper.rb</a></dt>
<dd>View helpers for basic functions used in various other helpers.</dd>
</dl>

### Views

All templates in the `list` and `crud` folders may be 'overriden' individually
in a respective view folder. Define the basic structure of your CRUD views
here and adapt it as required for each single model. Actually, the
`_list.html.erb` partial from the `list` folder gets overriden in the `crud`
folder already.

All templates are available as HAML as well.

#### List
<dl>
<dt>views/list/index.html.erb</dt>
<dd>The index view displaying a sortable table with all entries. If you have
<tt>search_columns</tt> defined for your controller, then a search box is
rendered as well.</dd>

<dt>views/list/_list.html.erb</dt>
<dd>A partial defining the table in the index view. To change the displayed
attributes for your list model, just create an own <tt>_list.html.erb</tt> in
your controller's view directory.</dd>

<dt>views/list/_search.html.erb</dt>
<dd>
A partial defining a simple search form that is displayed when
<tt>search_columns</tt> are defined in a subclassing controller.
</dd>

<dt>views/list/_actions_index.html.erb</dt>
<dd>The action links available in the index view. None by default.</dd>
</dl>


#### Crud
<dl>

<dt>views/crud/show.html.erb</dt>
<dd>The show view displaying all the attributes of one entry and the various
actions to perform on it.</dd>

<dt>views/crud/_attrs.html.erb</dt>
<dd>A partial defining the attributes to be displayed in the show view.</dd>

<dt>views/crud/_list.html.erb</dt>
<dd>
A partial defining the table in the index view with various links to
manipulate the entries.
</dd>

<dt>views/crud/new.html.erb</dt>
<dd>The view to create a new entry.</dd>

<dt>views/crud/edit.html.erb</dt>
<dd>The view to edit an existing entry.</dd>

<dt>views/crud/_form.html.erb</dt>
<dd>
The form used to create and edit entries. If you would like to customize
this form for various models, just create an own <tt>_form.html.erb</tt> in your
controller's view directory.
</dd>

<dt>views/crud/_actions_index.html.erb</dt>
<dd>The action links available in the index view.</dd>

<dt>views/crud/_actions_show.html.erb</dt>
<dd>The action links available in the show view.</dd>

<dt>views/crud/_actions_edit.html.erb</dt>
<dd>The action links available in the edit view.</dd>
</dl>


#### Various
<dl>

<dt>views/shared/_labeled.html.erb</dt>
<dd>Partial to define the layout for an arbitrary content with a label.</dd>

<dt>views/shared/_error_messages.html.erb</dt>
<dd>Partial to display the validation errors in Rails 2 style.</dd>

<dt>views/layouts/application.html.erb</dt>
<dd>An example layout showing how to use the <tt>@title</tt> and <tt>flash</tt>.</dd>

<dt>views/layouts/_flash.html.erb</dt>
<dd>An simple partial to display the various flash messages. Included from
<tt>crud.html.erb</tt>.</dd>

<dt>views/layouts/_nav.html.erb</dt>
<dd>An empty file to put your navigation into. Included from <tt>crud.html.erb</tt>.</dd>

<dt>app/assets/stylesheets/crud.scss</dt>
<dl>A simple SCSS with all the classes and ids used in the CRUD code.</dl>

<dt>app/assets/images/action/*.png</dt>
<dd>Some sample action icons from the <a href="http://openiconlibrary.sourceforge.net"> Open Icon Library</a>.</dd>

</dl>



### Tests
<dl>

<dt>test/support/crud_test_model.rb</dt>
<dd>A dummy model to run CRUD tests against.</dd>


<dt><a href="http://codez.ch/dry_crud?q=CustomAssertions">test/support/custom_assertions.rb</a></dt>
<dd>A handful of convenient assertions. Include this module into your <tt>test_helper.rb</tt> file.</dd>

<dt><a href="http://codez.ch/dry_crud?q=CrudControllerTestHelper">test/support/crud_controller_test_helper.rb</a></dt>
<dd>
A module to include into the functional tests for your CrudController
subclasses. Contains a handful of CRUD functionality tests for the
provided implementation. So for each new CRUD controller, you get 20 tests
for free.
</dd>

<dt>test/controllers/crud_test_models_controller_test.rb</dt>
<dd>Functional tests for the basic CrudController functionality.</dd>

<dt>test/helpers/*_test.rb</dt>
<dd>Tests for the provided helper implementations and a great base to test
your adaptions of the CRUD code.
</dd>

</dl>

### Specs

<dl>
<dt>spec/support/crud_controller_examples.rb</dt>
<dd>A whole set of shared exampled to include into your controller specs. See
`spec/controllers/crud_test_models_controller_spec.rb` for usage. So for
each new CRUD controller, you get all the basic specs for free.</dd>

<dt><a href="http://codez.ch/dry_crud?q=CrudControllerTestHelper::ClassMethods">spec/support/crud_controller_test_helper.rb</a></dt>
<dd>Convenience methods used by the crud controller examples.</dd>

<dt>spec/support/crud_test_model.rb</dt>
<dd>A dummy model to run CRUD tests against.</dd>

<dt>spec/controllers/crud_test_models_controller_spec.rb</dt>
<dd>Controller specs to test the basic CrudController functionality.</dd>

<dt>spec/helpers/*_spec.rb</dt>
<dd>The specs for all the helpers included in dry_crud and a great base to
test your adaptions of the CRUD code.</dd>
</dl>

