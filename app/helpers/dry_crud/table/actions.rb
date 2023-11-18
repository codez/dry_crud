module DryCrud
  module Table

    # Adds action columns to the table builder.
    # Predefined actions are available for show, edit and destroy.
    # Additionally, a special col type to define cells linked to the show page
    # of the row entry is provided.
    module Actions

      extend ActiveSupport::Concern

      included do
        delegate :link_to, :path_args, :edit_polymorphic_path, :ti,
                 to: :template
      end

      # Renders the passed attr with a link to the show action for
      # the current entry.
      # A block may be given to define the link path for the row entry.
      def attr_with_show_link(attr, &block)
        sortable_attr(attr) do |entry|
          link_to(format_attr(entry, attr), action_path(entry, &block))
        end
      end

      # Action column to show the row entry.
      # A block may be given to define the link path for the row entry.
      # If the block returns nil, no link is rendered.
      def show_action_col(**html_options, &block)
        action_col do |entry|
          path = action_path(entry, &block)
          if path
            table_action_link('zoom-in',
                              path,
                              **html_options.clone)
          end
        end
      end

      # Action column to edit the row entry.
      # A block may be given to define the link path for the row entry.
      # If the block returns nil, no link is rendered.
      def edit_action_col(**html_options, &block)
        action_col do |entry|
          path = action_path(entry, &block)
          if path
            path = edit_polymorphic_path(path) unless path.is_a?(String)
            table_action_link('pencil', path, **html_options.clone)
          end
        end
      end

      # Action column to destroy the row entry.
      # A block may be given to define the link path for the row entry.
      # If the block returns nil, no link is rendered.
      def destroy_action_col(**html_options, &block)
        action_col do |entry|
          path = action_path(entry, &block)
          if path
            table_action_link('trash',
                              path,
                              **html_options.merge(
                                data: { 'turbo-confirm': ti(:confirm_delete),
                                        'turbo-method': :delete }
                              ))
          end
        end
      end

      # Action column inside a table. No header.
      # The cell content should be defined in the passed block.
      def action_col(&block)
        col('', class: 'action', &block)
      end

      # Generic action link inside a table.
      def table_action_link(icon, url, **html_options)
        add_css_class(html_options, "bi-#{icon}")
        link_to('', url, html_options)
      end

      private

      # If a block is given, call it to get the path for the current row entry.
      # Otherwise, return the standard path args.
      def action_path(entry)
        block_given? ? yield(entry) : path_args(entry)
      end

    end

  end
end
