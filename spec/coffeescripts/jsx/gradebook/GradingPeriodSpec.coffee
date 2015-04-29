define [
  'react'
  'jquery'
  'underscore'
  'jsx/grading/gradingPeriod'
  'jquery.instructure_misc_plugins'
], (React, $, _, GradingPeriod) ->

  TestUtils = React.addons.TestUtils

  module 'GradingPeriod',
    setup: ->
      @fMessage = $.flashMessage
      @fError = $.flashError
      @hErrors = $.fn.hideErrors
      @eBox = $.fn.errorBox
      $.flashMessage = ->
      $.flashError = ->
      $.fn.hideErrors = ->
      $.fn.errorBox = ->
      @server = sinon.fakeServer.create()
      @sandbox = sinon.sandbox.create()
      ENV.GRADING_PERIODS_URL = "api/v1/courses/1/grading_periods"

      @createdPeriodData = "grading_periods":[
        {
          "id":"3", "start_date":"2015-04-20T05:00:00Z", "end_date":"2015-04-21T05:00:00Z",
          "weight":null, "title":"New Period!", "permissions": { "read":true, "manage":true }
        }
      ]
      @updatedPeriodData = "grading_periods":[
        {
          "id":"1", "startDate":"2015-03-01T06:00:00Z", "endDate":"2015-05-31T05:00:00Z",
          "weight":null, "title":"Updated Grading Period!", "permissions": { "read":true, "manage":true }
        }
      ]
      @server.respondWith "POST", ENV.GRADING_PERIODS_URL, [200, {"Content-Type":"application/json"}, JSON.stringify @createdPeriodData]
      @server.respondWith "PUT", ENV.GRADING_PERIODS_URL + "/1", [200, {"Content-Type":"application/json"}, JSON.stringify @updatedPeriodData]
      @props =
        id: "1"
        title: "Spring"
        startDate: new Date("2015-03-01T00:00:00Z")
        endDate: new Date("2015-05-31T00:00:00Z")
        weight: null
        disabled: false
        permissions:
          read: true
          manage: true
        cannotDelete: -> false
        onDeleteGradingPeriod: ->
        updateGradingPeriodCollection: ->
      @gradingPeriod = TestUtils.renderIntoDocument(GradingPeriod(@props))
      @server.respond()
    teardown: ->
      React.unmountComponentAtNode(@gradingPeriod.getDOMNode().parentNode)
      ENV.GRADING_PERIODS_URL = null
      $.flashMessage = @fMessage
      $.flashError = @fError
      $.fn.hideErrors = @hErrors
      $.fn.errorBox = @eBox
      @server.restore()
      @sandbox.restore()

  test 'sets initial state properly', ->
    deepEqual @gradingPeriod.state.id, @props.id
    deepEqual @gradingPeriod.state.title, @props.title
    deepEqual @gradingPeriod.state.startDate, @props.startDate
    deepEqual @gradingPeriod.state.endDate, @props.endDate
    deepEqual @gradingPeriod.state.weight, @props.weight
    deepEqual @gradingPeriod.state.permissions, @props.permissions
    deepEqual @gradingPeriod.state.shouldUpdateBeDisabled, true

  test 'handleDateChange changes the state of the respective date passed in', ->
    startDateInput = @gradingPeriod.refs.startDate.getDOMNode()
    newDate = new Date("Feb 20, 2015 2:55 am")
    startDateInput.value = $.datetimeString(newDate, { format: "medium", localized: false })
    fakeEvent = { target: { name: "startDate", value: "Feb 20, 2015 2:55 am" } }
    $(startDateInput).blur()
    @gradingPeriod.handleDateChange(fakeEvent)
    deepEqual @gradingPeriod.state.startDate.toUTCString(), new Date("Feb 20, 2015 2:55 am").toUTCString()

  test 'handleDateChange calls replaceInputWithDate', ->
    fakeEvent = { target: { name: "startDate", value: "Feb 20, 2015 2:55 am" } }
    replaceInputWithDate = @sandbox.stub(@gradingPeriod, 'replaceInputWithDate')
    @gradingPeriod.handleDateChange(fakeEvent)
    ok replaceInputWithDate.calledOnce

  test 'handleDateChange calls setUpdateButtonState', ->
    fakeEvent = { target: { name: "startDate", value: "Feb 20, 2015 2:55 am" } }
    setUpdateButton = @sandbox.stub(@gradingPeriod, 'setUpdateButtonState')
    @gradingPeriod.handleDateChange(fakeEvent)
    ok setUpdateButton.calledOnce

  test 'handleDateChange calls updateGradingPeriodCollection', ->
    fakeEvent = { target: { name: "startDate", value: "Feb 20, 2015 2:55 am" } }
    update = @sandbox.stub(@gradingPeriod.props, 'updateGradingPeriodCollection')
    @gradingPeriod.handleDateChange(fakeEvent)
    ok update.calledOnce

  test 'formatDataForSubmission returns the title, startDate, and endDate with keys snake cased', ->
    expectedOutput =
      title: @gradingPeriod.state.title
      start_date: @gradingPeriod.state.startDate
      end_date: @gradingPeriod.state.endDate
    deepEqual @gradingPeriod.formatDataForSubmission(), expectedOutput

  test 'isStartDateBeforeEndDate returns true if the start date is before the end date', ->
    deepEqual @gradingPeriod.isStartDateBeforeEndDate(), true

  test 'isStartDateBeforeEndDate returns false if the start date is equal to the end date', ->
    @gradingPeriod.setState({startDate: @gradingPeriod.state.endDate})
    deepEqual @gradingPeriod.isStartDateBeforeEndDate(), false

  test 'isStartDateBeforeEndDate returns false if the start date is after the end date', ->
    startDate = new Date("2020-06-01T00:00:00Z")
    @gradingPeriod.setState({startDate: startDate})
    deepEqual @gradingPeriod.isStartDateBeforeEndDate(), false

  test 'isNewGradingPeriod returns false if the id does not contain "new"', ->
    deepEqual @gradingPeriod.isNewGradingPeriod(), false

  test 'isNewGradingPeriod returns true if the id contains "new"', ->
    @gradingPeriod.setState({id: "new1"})
    deepEqual @gradingPeriod.isNewGradingPeriod(), true

  test 'setUpdateButtonState sets shouldUpdateBeDisabled to false if the form is complete', ->
    @sandbox.stub(@gradingPeriod, 'formIsComplete', -> true)
    deepEqual @gradingPeriod.state.shouldUpdateBeDisabled, true
    @gradingPeriod.setUpdateButtonState()
    deepEqual @gradingPeriod.state.shouldUpdateBeDisabled, false

  test 'setUpdateButtonState sets shouldUpdateBeDisabled to true if the form is not complete', ->
    @sandbox.stub(@gradingPeriod, 'formIsComplete', -> false)
    @gradingPeriod.setState({shouldUpdateBeDisabled: false})
    @gradingPeriod.setUpdateButtonState()
    deepEqual @gradingPeriod.state.shouldUpdateBeDisabled, true

  test 'formIsComplete returns true if title, startDate, and endDate are all non-blank', ->
    deepEqual @gradingPeriod.formIsComplete(), true

  test 'formIsComplete returns false if the title is blank, or only spaces', ->
    @gradingPeriod.setState({title: ""})
    deepEqual @gradingPeriod.formIsComplete(), false
    @gradingPeriod.setState({title: "            "})
    deepEqual @gradingPeriod.formIsComplete(), false

  test 'formIsComplete returns false if the startDate is not a valid date', ->
    @gradingPeriod.setState({startDate: new Date("i love lamp")})
    deepEqual @gradingPeriod.formIsComplete(), false
    @gradingPeriod.setState({startDate: new Date("2010-15-28T00:00:00Z")})
    deepEqual @gradingPeriod.formIsComplete(), false

  test 'formIsComplete returns false if the endDate is not a valid date', ->
    @gradingPeriod.setState({endDate: new Date("big gulps, huh?")})
    deepEqual @gradingPeriod.formIsComplete(), false
    @gradingPeriod.setState({endDate: new Date("2030-15-28T00:00:00Z")})
    deepEqual @gradingPeriod.formIsComplete(), false

  test 'handleTitleChange changes the title state', ->
    fakeEvent = { target: { name: "title", value: "MXP: Most Xtreme Primate" } }
    @gradingPeriod.handleTitleChange(fakeEvent)
    deepEqual @gradingPeriod.state.title, "MXP: Most Xtreme Primate"

  test 'handleTitleChange calls setUpdateButtonState', ->
    fakeEvent = { target: { name: "title", value: "MXP: Most Xtreme Primate" } }
    setUpdateButton = @sandbox.stub(@gradingPeriod, 'setUpdateButtonState')
    @gradingPeriod.handleTitleChange(fakeEvent)
    ok setUpdateButton.calledOnce

  test 'handleTitleChange calls updateGradingPeriodCollection', ->
    fakeEvent = { target: { name: "title", value: "MXP: Most Xtreme Primate" } }
    update = @sandbox.stub(@gradingPeriod.props, 'updateGradingPeriodCollection')
    @gradingPeriod.handleTitleChange(fakeEvent)
    ok update.calledOnce

  test 'replaceInputWithDate calls formatDateForDisplay', ->
    formatDate = @sandbox.stub(@gradingPeriod, 'formatDateForDisplay')
    @gradingPeriod.replaceInputWithDate(@gradingPeriod.refs.startDate)
    ok formatDate.calledOnce

  test 'triggerDeleteGradingPeriod calls onDeleteGradingPeriod', ->
    deletePeriod = @sandbox.stub(@gradingPeriod.props, 'onDeleteGradingPeriod')
    @gradingPeriod.triggerDeleteGradingPeriod()
    ok deletePeriod.calledOnce

  test 'saveGradingPeriod makes an AJAX call if the start date is before the end date', ->
    @sandbox.stub(@gradingPeriod, 'isStartDateBeforeEndDate', -> true)
    ajax = @sandbox.spy($, 'ajax')
    @gradingPeriod.saveGradingPeriod()
    ok ajax.calledOnce

  test 'saveGradingPeriod does not make an AJAX call if the start date is not before the end date', ->
    @sandbox.stub(@gradingPeriod, 'isStartDateBeforeEndDate', -> false)
    ajax = @sandbox.spy($, 'ajax')
    @gradingPeriod.saveGradingPeriod()
    ok ajax.notCalled

  test 'saveGradingPeriod should re-assign the id if the period is new', ->
    @sandbox.stub(@gradingPeriod, 'isStartDateBeforeEndDate', -> true)
    @gradingPeriod.setState({id: "new1"})
    @gradingPeriod.saveGradingPeriod()
    @server.respond()
    deepEqual @gradingPeriod.state.id, '3'

  test 'saveGradingPeriod should not re-assign the id if the period is not new', ->
    @sandbox.stub(@gradingPeriod, 'isStartDateBeforeEndDate', -> true)
    idBeforeSaving = @gradingPeriod.state.id
    @gradingPeriod.saveGradingPeriod()
    @server.respond()
    deepEqual @gradingPeriod.state.id, idBeforeSaving

  test 'saveGradingPeriod calls updateGradingPeriodCollection for new periods', ->
    @sandbox.stub(@gradingPeriod, 'isStartDateBeforeEndDate', -> true)
    update = @sandbox.stub(@gradingPeriod.props, 'updateGradingPeriodCollection')
    @gradingPeriod.setState({id: "new1"})
    @gradingPeriod.saveGradingPeriod()
    @server.respond()
    ok update.calledOnce

  test 'saveGradingPeriod calls updateGradingPeriodCollection for existing periods', ->
    @sandbox.stub(@gradingPeriod, 'isStartDateBeforeEndDate', -> true)
    update = @sandbox.stub(@gradingPeriod.props, 'updateGradingPeriodCollection')
    @gradingPeriod.saveGradingPeriod()
    @server.respond()
    ok update.calledOnce
