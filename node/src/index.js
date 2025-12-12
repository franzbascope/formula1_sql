import { importCSV } from "./import-csv.js";

async function importCircuits() {
    console.log('Starting import...');
    
    try {
        // circuits
        // await importCSV(
        //     'circuits',
        //     'circuit_id,circuit_ref,name,location,country,lat,lng,alt,url',
        //     './f1_dataset/circuits.csv'
        // );
        // drivers

        // await importCSV(
        //     'drivers',
        //     'driver_id,driver_ref,driver_number,driver_code,forename,surname,date_of_birth,nationality,url',
        //     './f1_dataset/drivers.csv'
        // );

        await importCSV(
            'constructors',
            'constructorId,constructorRef,name,nationality,url',
            './f1_dataset/constructors.csv'
        );

    } catch (err) {
        console.log('Import failed:', err.message);
    }
}

importCircuits();