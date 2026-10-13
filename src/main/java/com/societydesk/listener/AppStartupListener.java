package com.societydesk.listener;

import com.societydesk.dao.UserDAO;
import com.societydesk.job.EscalationJob;
import com.societydesk.model.User;
import com.societydesk.util.DBConnection;
import com.societydesk.util.PasswordUtil;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebListener
public class AppStartupListener implements ServletContextListener {
    private static final Logger LOGGER = Logger.getLogger(AppStartupListener.class.getName());
    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        LOGGER.info("SocietyDesk Web Application is initializing...");

        // Ensure default accounts exist
        ensureDefaultUsersExist();

        // Start background SLA escalation scheduler: runs every 60 seconds
        scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "SocietyDesk-Escalation-Worker");
            t.setDaemon(true);
            return t;
        });

        int defaultAdminId = 1; // Default system actor id
        scheduler.scheduleWithFixedDelay(new EscalationJob(defaultAdminId), 15, 60, TimeUnit.SECONDS);
        LOGGER.info("SLA Escalation Scheduler started. Interval: 60s.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        LOGGER.info("SocietyDesk Web Application is stopping...");
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdownNow();
            LOGGER.info("Escalation Scheduler stopped.");
        }
        DBConnection.shutdown();
    }

    private void ensureDefaultUsersExist() {
        try {
            UserDAO dao = new UserDAO();

            // 1. Admin
            if (dao.findByEmail("admin@societydesk.com") == null) {
                User admin = new User("Society Admin", "admin@societydesk.com",
                        PasswordUtil.hashPassword("Password@123"), "ADMIN", null, "9876500001", "ACTIVE");
                dao.create(admin);
                LOGGER.info("Seeded default admin user: admin@societydesk.com");
            }

            // 2. Committee Member
            if (dao.findByEmail("committee@societydesk.com") == null) {
                User committee = new User("Rajesh Sharma (Secretary)", "committee@societydesk.com",
                        PasswordUtil.hashPassword("Password@123"), "COMMITTEE", null, "9876500002", "ACTIVE");
                dao.create(committee);
                LOGGER.info("Seeded default committee user: committee@societydesk.com");
            }

            // 3. Technician
            if (dao.findByEmail("technician@societydesk.com") == null) {
                User tech = new User("Suresh Kumar (Electrician)", "technician@societydesk.com",
                        PasswordUtil.hashPassword("Password@123"), "TECHNICIAN", null, "9876500003", "ACTIVE");
                dao.create(tech);
                LOGGER.info("Seeded default technician user: technician@societydesk.com");
            }

            // 4. Resident
            if (dao.findByEmail("resident@societydesk.com") == null) {
                User resident = new User("Ananya Verma", "resident@societydesk.com",
                        PasswordUtil.hashPassword("Password@123"), "RESIDENT", 1, "9876500004", "ACTIVE");
                dao.create(resident);
                LOGGER.info("Seeded default resident user: resident@societydesk.com");
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Auto-seeding default accounts skipped: " + e.getMessage());
        }
    }
}
