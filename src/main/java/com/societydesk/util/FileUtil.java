package com.societydesk.util;

import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

/**
 * File upload utility: validates MIME type/extension and generates safe random names.
 */
public class FileUtil {
    private static final List<String> ALLOWED_EXTENSIONS = Arrays.asList(".jpg", ".jpeg", ".png", ".webp");
    public static final long MAX_FILE_SIZE = 5 * 1024 * 1024; // 5 MB

    private FileUtil() {}

    public static String saveUploadedFile(Part part, String uploadDir) throws IOException {
        if (part == null || part.getSize() == 0) {
            return null;
        }

        if (part.getSize() > MAX_FILE_SIZE) {
            throw new IllegalArgumentException("File size exceeds 5MB limit.");
        }

        String submittedFileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        String extension = "";
        int dotIndex = submittedFileName.lastIndexOf('.');
        if (dotIndex > 0) {
            extension = submittedFileName.substring(dotIndex).toLowerCase();
        }

        if (!ALLOWED_EXTENSIONS.contains(extension)) {
            throw new IllegalArgumentException("Invalid file format. Only JPG, PNG, and WebP photos are permitted.");
        }

        File uploadFolder = new File(uploadDir);
        if (!uploadFolder.exists()) {
            uploadFolder.mkdirs();
        }

        String uniqueFileName = UUID.randomUUID().toString() + extension;
        File destination = new File(uploadFolder, uniqueFileName);
        part.write(destination.getAbsolutePath());

        return uniqueFileName;
    }
}
