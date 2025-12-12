import { getConnection } from "./db.js";
import fs from "fs";
import csv from "csv-parser";
import path from "path";

function parseCSV(csvPath, skipHeader = true) {
  return new Promise((resolve, reject) => {
    const rows = [];
    let isFirstRow = true;

    fs.createReadStream(csvPath)
      .pipe(csv({ headers: false }))
      .on("data", (row) => {
        if (skipHeader && isFirstRow) {
          isFirstRow = false;
        } else {
          rows.push(Object.values(row));
        }
      })
      .on("end", () => resolve(rows))
      .on("error", reject);
  });
}

async function importCSV(tableName, columns, csvPath) {
  let connection;

  try {
    const resolvedPath = path.resolve(csvPath);
    if (!fs.existsSync(resolvedPath)) {
      throw new Error(`CSV file not found: ${resolvedPath}`);
    }

    const data = await parseCSV(csvPath, true); // Skip header
    if (data.length === 0) {
      console.log("No data found in CSV");
      return;
    }

    console.log(`Importing ${data.length} rows to ${tableName}`);

    connection = await getConnection();
    const columnList = columns.split(",").map((col) => col.trim());

    if (data[0].length !== columnList.length) {
      throw new Error(
        `Column count mismatch: CSV has ${data[0].length} columns, table expects ${columnList.length}`
      );
    }

    // Create Oracle bind placeholders :1, :2, :3, etc.
    const placeholders = columnList.map((_, i) => `:${i + 1}`).join(",");
    const sql = `INSERT INTO ${tableName} (${columnList.join(
      ","
    )}) VALUES (${placeholders})`;
    console.log(`Prepared SQL: ${sql}`);

    let inserted = 0;
    let errors = 0;

    for (let i = 0; i < data.length; i++) {
      try {
        // Modify data for Oracle if necessary (e.g., convert empty strings to null)

        // Find if there is a value in data[i] with format yyy-mm-dd
        // And add append DATE before
        data[i] = data[i].map((value) => {
          if (/^\d{4}-\d{2}-\d{2}$/.test(value)) {
            return null
          }
          if(value === `\N`){
            return null
          }
          return value;
        });

        console.log(`Running sql : ${sql} with data: ${data[i]}`);
        await connection.execute(sql, data[i]);
        console.log(`Row ${i + 1} inserted`);
        inserted++;
      } catch (err) {
        errors++;
        console.log(`Row ${i + 1} error:`, err.message);
      }
    }

    await connection.commit();
    console.log(`Completed: ${inserted} inserted, ${errors} failed`);
  } catch (err) {
    console.log("Import failed:", err.message);
    if (connection) await connection.rollback();
    throw err;
  } finally {
    if (connection) await connection.close();
  }
}

export { importCSV };
