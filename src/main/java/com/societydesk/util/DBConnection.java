package com.societydesk.util;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DBConnection provides high-performance connection pooling via HikariCP.
 */
public class DBConnection {
    private static final Logger LOGGER = Logger.getLogger(DBConnection.class.getName());
    private static HikariDataSource dataSource;

    static {
        try {
            Properties props = new Properties();
            try (InputStream input = DBConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
                if (input == null) {
                    throw new RuntimeException("Unable to find db.properties in classpath");
                }
                props.load(input);
            }

            HikariConfig config = new HikariConfig();
            config.setDriverClassName(props.getProperty("db.driver", "com.mysql.cj.jdbc.Driver"));
            config.setJdbcUrl(props.getProperty("db.url"));
            config.setUsername(props.getProperty("db.username"));
            config.setPassword(props.getProperty("db.password"));

            config.setMaximumPoolSize(Integer.parseInt(props.getProperty("hikari.maximumPoolSize", "10")));
            config.setMinimumIdle(Integer.parseInt(props.getProperty("hikari.minimumIdle", "2")));
            config.setIdleTimeout(Long.parseLong(props.getProperty("hikari.idleTimeout", "30000")));
            config.setConnectionTimeout(Long.parseLong(props.getProperty("hikari.connectionTimeout", "20000")));
            config.setMaxLifetime(Long.parseLong(props.getProperty("hikari.maxLifetime", "1800000")));

            config.addDataSourceProperty("cachePrepStmts", "true");
            config.addDataSourceProperty("prepStmtCacheSize", "250");
            config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");

            dataSource = new HikariDataSource(config);
            LOGGER.info("HikariCP connection pool initialized successfully.");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to initialize DB connection pool: " + e.getMessage(), e);
            throw new ExceptionInInitializerError(e);
        }
    }

    private DBConnection() {
        // Prevent instantiation
    }

    public static Connection getConnection() throws SQLException {
        if (dataSource == null) {
            throw new SQLException("DataSource is not initialized.");
        }
        return dataSource.getConnection();
    }

    public static void shutdown() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
            LOGGER.info("HikariCP connection pool closed.");
        }
    }
}
