package com.societydesk;

import org.apache.catalina.WebResourceRoot;
import org.apache.catalina.core.StandardContext;
import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.webresources.DirResourceSet;
import org.apache.catalina.webresources.StandardRoot;
import org.apache.tomcat.util.descriptor.web.ErrorPage;

import java.io.File;
import java.io.IOException;
import java.net.ServerSocket;

/**
 * ServerMain provides an embedded Tomcat launcher for SocietyDesk.
 * Run directly with: mvn compile exec:java
 */
public class ServerMain {
    public static void main(String[] args) throws Exception {
        int preferredPort = 8085;
        String portProp = System.getProperty("server.port");
        int port;

        if (portProp != null && !portProp.trim().isEmpty()) {
            port = Integer.parseInt(portProp.trim());
        } else {
            port = findAvailablePort(preferredPort);
        }

        Tomcat tomcat = new Tomcat();
        tomcat.setPort(port);
        tomcat.getConnector(); // Initialize connector

        String webappDirLocation = "src/main/webapp";
        File webappDir = new File(webappDirLocation);

        StandardContext ctx = (StandardContext) tomcat.addWebapp("", webappDir.getAbsolutePath());
        ctx.setParentClassLoader(ServerMain.class.getClassLoader());

        // Configure error pages programmatically on context
        ErrorPage ep404 = new ErrorPage();
        ep404.setErrorCode(404);
        ep404.setLocation("/WEB-INF/views/common/404.jsp");
        ctx.addErrorPage(ep404);

        ErrorPage ep403 = new ErrorPage();
        ep403.setErrorCode(403);
        ep403.setLocation("/WEB-INF/views/common/403.jsp");
        ctx.addErrorPage(ep403);

        ErrorPage ep500 = new ErrorPage();
        ep500.setErrorCode(500);
        ep500.setLocation("/WEB-INF/views/common/500.jsp");
        ctx.addErrorPage(ep500);

        // Declare an alternative location for "WEB-INF/classes"
        File additionWebInfClasses = new File("target/classes");
        WebResourceRoot resources = new StandardRoot(ctx);
        if (additionWebInfClasses.exists()) {
            resources.addPreResources(new DirResourceSet(resources, "/WEB-INF/classes",
                    additionWebInfClasses.getAbsolutePath(), "/"));
        }
        ctx.setResources(resources);

        System.out.println("==================================================================");
        System.out.println("  SocietyDesk Web Application is Running Successfully!");
        System.out.println("  Open in Browser: http://localhost:" + port);
        System.out.println("  Press Ctrl+C in this terminal to stop.");
        System.out.println("==================================================================");

        tomcat.start();
        tomcat.getServer().await();
    }

    private static int findAvailablePort(int preferred) {
        int[] candidates = {preferred, 8085, 8088, 9090, 8081, 8080};
        for (int p : candidates) {
            try (ServerSocket socket = new ServerSocket(p)) {
                return p;
            } catch (IOException ignored) {}
        }
        return preferred;
    }
}
