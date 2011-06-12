dataSource {
    pooled = true
    driverClassName = "org.postgresql.Driver"
    username = "eliot"
    password = "eliot"
}
hibernate {
    cache.use_second_level_cache = true
    cache.use_query_cache = true
    cache.provider_class = 'net.sf.ehcache.hibernate.EhCacheProvider'
}
// environment specific settings
environments {
    development {
        dataSource {
            url = "jdbc:postgresql://localhost:5433/eliot-tdbase-dev"
        }
    }
    test {
        dataSource {
            url = "jdbc:postgresql://localhost:5433/eliot-tdbase-test"
        }
    }

}
