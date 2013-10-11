package org.lilie.services.eliot

import org.codehaus.groovy.grails.web.errors.ErrorsViewStackTracePrinter
import org.codehaus.groovy.grails.web.errors.GrailsExceptionResolver
import org.springframework.util.StringUtils

/**
 * @author John Tranier
 */
class RenderCatchedExceptionTagLib {

  ErrorsViewStackTracePrinter errorsViewStackTracePrinter

  def renderStackTrace = { attrs ->
    Throwable exception = attrs.exception

    if (!(exception instanceof Throwable)) {
      return
    }

    out << "<b>Exception</b>:"
    out << "<pre class='stack'>"
    out << "${exception.getClass()}: ${exception.message.encodeAsHTML()}\n"
    Throwable cause = exception.cause
    while(cause) {
      out << "Caused by ${cause.getClass()}: ${cause.message.encodeAsHTML()}"
      cause = cause.getCause()
    }
    out << "</pre>"

    def trace = errorsViewStackTracePrinter.prettyPrint(exception.cause ?: exception)
    out << "<b>Stacktrace</b>:"
    if (StringUtils.hasText(trace.trim())) {
      out << '<pre class="stack">'
      out << trace.encodeAsHTML()
      out << '</pre>'
    }
  }
}
