@NestedItemPicker = (element, options) ->
  @type = null
  @$element = null
  @options = null
  @data = null
  @currentData = null
  @level = null

  @init 'nestedItemPicker', element, options

@NestedItemPicker::init = (type, element, options) ->
  @type = type
  @$element = $(element)
  @options = @getOptions(options)
  @data = @options.data
  @currentData = @data

  @updateList()

  # bind events here
  self = this
  @$element.on 'DOMSubtreeModified', '.eui-item-path', ->
    self.updateList()

  this

@NestedItemPicker.DEFAULTS = {
  field_prefix: 'draft'
}

@NestedItemPicker::getDefaults = ->
  NestedItemPicker.DEFAULTS

@NestedItemPicker::getOptions = (options) ->
  options = $.extend({}, @getDefaults(), @$element.data(), options)
  options


@NestedItemPicker::getParents = () ->
  pickerElement = @$element
  values = []
  items = []
  parents = []

  itemElements = pickerElement.find('.eui-item-path > li').not('.eui-item-path > li.list-title')
  $.each itemElements, (index, element) ->
    items.push $(element).text()
  items

@NestedItemPicker::getValues = () ->
  pickerElement = @$element
  values = []

  finalOption = pickerElement.find('.final-option-selected')

  parentItems = @getParents()
  if finalOption.length > 0
    $.each finalOption, (index, option) ->
      items = parentItems.slice()
      items.push option.text
      values.push items.join(' > ')
  else
    values.push parentItems.join(' > ')

  values

@NestedItemPicker::resetPicker = ->
  @$element.find('.eui-item-path > li.list-title').click()
  @updateList()

@NestedItemPicker::sortItemList = (items) ->
  sortedItems = items.sort (a, b) ->
    if a.value > b.value
      1
    else if a.value < b.value
      -1
    else
      0

@NestedItemPicker::updateList = ->
  selectedValues = @getValues()
  selectedItems = []
  if selectedValues.length > 0
    selectedItems = @getValues()[0].split(' > ')

  itemList = @$element.find('.eui-item-list-pane > ul')
  $(itemList).find('li.item').remove()

  newItems = []
  newItem = {}
  if selectedItems.length == 0
    $.each @data.category, (index, item) ->
      newItem = {}
      newItem.value = item.value
      newItem.class = if item.subfields == undefined then 'final-option' else 'item-parent'
      newItems.push newItem
  else
    # traverse this.data with item values and display subfields
    arrayType = 'category'
    array = @data[arrayType]
    values = undefined
    $.each selectedItems, (index, selectedItem) ->
      $.grep array, (item) ->
        if item.value == selectedItem
          arrayType = item.subfields[0]
          array = item[arrayType]

      if index + 1 == selectedItems.length
        values = array

    @currentData = stuff: values

    $.each values, (index, item) ->
      newItem = {}
      newItem.value = item.value
      newItem.class = if item.subfields == undefined then 'final-option' else 'item-parent'
      newItems.push newItem

  newItems = @sortItemList newItems

  $.each newItems, (index, item) ->
    li = $('<li/>')
    $('<a/>',
      href: 'javascript:void(0);'
      class: item.class
      text: item.value).appendTo li
    $(li).addClass('item').appendTo itemList
