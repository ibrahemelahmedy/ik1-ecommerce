import fs from 'fs';
import path from 'path';
import crypto from 'crypto';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';
import { GoogleGenAI } from '@google/genai';

dotenv.config();

// Define __dirname for ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Ensure the API key is present
const apiKey = process.env.GEMINI_API_KEY;
if (!apiKey) {
  console.error("Error: GEMINI_API_KEY is not defined in the environment or .env file.");
  process.exit(1);
}

// Initialize the Google Gen AI client
const ai = new GoogleGenAI({ apiKey: apiKey });

// Target base directory
const baseDir = path.resolve(__dirname, '../src/assets/pic/products');
const uncategorizedDir = path.join(baseDir, 'uncategorized');
const jsonFilePath = path.join(baseDir, 'products.json');

// Sleep utility function to handle rate limiting
const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));

// Supported image extensions
const imageExts = new Set(['.jpg', '.jpeg', '.png', '.webp', '.avif']);

// Schema definition for Structured Output from Gemini
const responseSchema = {
    type: "OBJECT",
    properties: {
        isProduct: {
            type: "BOOLEAN",
            description: "true if it's a clear product. false if it's a background, icon, logo, UI element, etc."
        },
        category: {
            type: "STRING",
            description: "Main category (e.g., 'clothing', 'electronics', 'furniture'). Lowercase only."
        },
        subcategory: {
            type: "STRING",
            description: "Subcategory (e.g., 'men', 'laptops', 'chairs'). Lowercase only."
        },
        extraDetails: {
            type: "STRING",
            description: "Additional details (e.g., 'blue', 'leather', 'rgb'). Lowercase only."
        },
        suggestedFilename: {
            type: "STRING",
            description: "Professional SEO naming, lowercase, words separated by hyphens (e.g., 'man-shirt-blue'). NO extension."
        }
    },
    required: ["isProduct", "category", "subcategory", "extraDetails", "suggestedFilename"]
};

/**
 * Generate a unique filename if it already exists avoiding overwrites
 */
function getUniqueFilename(targetDir, desiredName, ext) {
    let finalName = `${desiredName}${ext}`;
    let counter = 1;
    while (fs.existsSync(path.join(targetDir, finalName))) {
        finalName = `${desiredName}-${counter}${ext}`;
        counter++;
    }
    return finalName;
}

/**
 * Converts a local file to the inlineData format expected by Gemini
 */
function fileToGenerativePart(filePath, mimeType) {
    return {
        inlineData: {
            data: Buffer.from(fs.readFileSync(filePath)).toString("base64"),
            mimeType
        },
    };
}

/**
 * Maps extension to mime type
 */
function getMimeType(ext) {
    if (ext === '.jpg' || ext === '.jpeg') return 'image/jpeg';
    if (ext === '.png') return 'image/png';
    if (ext === '.webp') return 'image/webp';
    if (ext === '.avif') return 'image/avif';
    return 'image/jpeg'; // fallback
}

/**
 * Uses Gemini API to categorize the image
 */
async function analyzeImage(filePath, ext) {
    const mimeType = getMimeType(ext);
    const imagePart = fileToGenerativePart(filePath, mimeType);

    const prompt = `You are an expert E-commerce product taxonomist and image analyzer.
Analyze the provided image and extract product information.
If the image is not a product (like a logo, background, or UI icon), set 'isProduct' to false.
Otherwise, categorize it accurately, give it a clean SEO-friendly name, and extract details.`;

    try {
        const response = await ai.models.generateContent({
            model: 'gemini-2.5-flash',
            contents: [prompt, imagePart],
            config: {
                responseMimeType: "application/json",
                responseSchema: responseSchema,
                temperature: 0.2 // keep it deterministic
            }
        });

        const jsonText = response.text;
        return JSON.parse(jsonText);
    } catch (error) {
        console.error(`Failed to analyze image: ${filePath}`, error);
        return null;
    }
}

/**
 * Main process loop
 */
async function main() {
    console.log(`Scanning base directory: ${baseDir}`);
    
    // Ensure base directory exists
    if (!fs.existsSync(baseDir)) {
        console.error(`Base directory does not exist: ${baseDir}`);
        console.error(`Please create it or adjust the path.`);
        process.exit(1);
    }

    // Load existing products if any
    let products = [];
    if (fs.existsSync(jsonFilePath)) {
        try {
            products = JSON.parse(fs.readFileSync(jsonFilePath, 'utf8'));
            if (!Array.isArray(products)) products = [];
        } catch (err) {
            console.warn('Could not parse existing products.json, starting fresh.');
        }
    }

    const allFiles = fs.readdirSync(baseDir);
    const imageFiles = [];
    
    for (const file of allFiles) {
        const filePath = path.join(baseDir, file);
        const stat = fs.statSync(filePath);
        if (!stat.isFile()) continue;
        const ext = path.extname(file).toLowerCase();
        if (imageExts.has(ext)) imageFiles.push({ file, filePath, ext });
    }

    console.log(`Found ${imageFiles.length} images to process.`);

    let processedCount = 0;
    const batchSize = 10;

    for (let i = 0; i < imageFiles.length; i += batchSize) {
        const batch = imageFiles.slice(i, i + batchSize);
        console.log(`\n--- Processing batch ${Math.floor(i / batchSize) + 1}/${Math.ceil(imageFiles.length / batchSize)} ---`);
        
        const promises = batch.map(async ({ file, filePath, ext }, index) => {
            // Add staggered delay of 1 second between requests in the batch
            await sleep(index * 1000);
            
            console.log(`Processing: ${file}`);
            const result = await analyzeImage(filePath, ext);
            
            if (!result) {
                console.log(`Skipping ${file} due to analysis failure.`);
            } else {
                console.log(`Result for ${file}: category=${result.category}, subcategory=${result.subcategory}, name=${result.suggestedFilename}`);

                if (!result.isProduct) {
                    if (!fs.existsSync(uncategorizedDir)) fs.mkdirSync(uncategorizedDir, { recursive: true });
                    const targetPath = path.join(uncategorizedDir, file);
                    fs.renameSync(filePath, targetPath);
                } else {
                    const safeCategory = result.category.replace(/[^a-z0-9-]/gi, '-').toLowerCase() || 'other';
                    const safeSubcat = result.subcategory.replace(/[^a-z0-9-]/gi, '-').toLowerCase() || 'other';
                    const safeName = result.suggestedFilename.replace(/[^a-z0-9-]/gi, '-').toLowerCase() || 'product';

                    const targetDir = path.join(baseDir, safeCategory, safeSubcat);
                    if (!fs.existsSync(targetDir)) fs.mkdirSync(targetDir, { recursive: true });

                    const finalFilename = getUniqueFilename(targetDir, safeName, ext);
                    const targetPath = path.join(targetDir, finalFilename);

                    fs.renameSync(filePath, targetPath);

                    const productId = crypto.randomUUID();
                    const imageRelativePath = `@/assets/pic/products/${safeCategory}/${safeSubcat}/${finalFilename}`;

                    products.push({
                        id: productId,
                        name: `${result.suggestedFilename.replace(/-/g, ' ')} ${result.extraDetails}`.trim(),
                        category: safeCategory,
                        subcategory: safeSubcat,
                        image: imageRelativePath
                    });
                }
            }
            
            processedCount++;
            if (processedCount % 5 === 0) {
                console.log(`[Progress] Processed ${processedCount}/${imageFiles.length} images...`);
            }
        });

        // Wait for the entire batch to finish before moving to the next batch
        await Promise.all(promises);

        // Update JSON file incrementally after each batch
        fs.writeFileSync(jsonFilePath, JSON.stringify(products, null, 2), 'utf8');
        console.log(`Batch finished. Progress saved to ${path.basename(jsonFilePath)}`);
    }

    console.log(`\nFinished processing all files.`);
}

main().catch(err => {
    console.error("An unexpected error occurred:", err);
});
