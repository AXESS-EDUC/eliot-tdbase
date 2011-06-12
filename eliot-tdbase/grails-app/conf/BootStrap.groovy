import liquibase.resource.ClassLoaderResourceAccessor

class BootStrap {

  def init = { servletContext ->
    ClassLoaderResourceAccessor classLoaderResourceAccessor = new ClassLoaderResourceAccessor()
    classLoaderResourceAccessor.getResourceAsStream('changelogs/scolarite/release-changes.xml').eachLine {
      println it
    }

  }

  def destroy = {
  }
}
