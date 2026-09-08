from flask import Flask, render_template, request, jsonify,session
from flask import request, jsonify
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import (r2_score, mean_squared_error)
import secrets
import io
import json
import os
import joblib
import uuid
import pandas as pd
import numpy as np

#----- helper functions-----
from routes.loadActiveDataset import get_active_dataframe, save_active_dataframe
#------end------

# -----models routes
from routes.models.linearRegression import linearRegression
from routes.models.logisticRegression import logisticRegression
#------end------

from routes.login import auth_bp, oauth
from routes.config import get_db
from routes.saveCopy import saveCopies_bp 
from routes.loadDatasetandCopy import loadDataset_bp
from routes.getAllcopies import viewCopies_bp
from routes.getDatasetsofLogged import datasets_bp
from routes.rename_dataset import renamedatasets_bp
from routes.changeTheme import themeauth_bp
from routes.dataVisualization import dataVisualize_bp 
from routes.overview import overview_bp

# profile page routes
from routes.profile.profile_details import profile_details_bp
app = Flask(__name__)




def generate_secret_key():
    return secrets.token_hex(32)   # 64-character random key

app.secret_key = generate_secret_key()

oauth.init_app(app)

# Global dataframe (for a single-user demo)
df = pd.DataFrame()

# Temporary server-side storage for saved/run models
RUNNED_MODELS_CACHE = {}
MODEL_DIR = "saved_models"
UPLOAD_FOLDER = "datasets"
os.makedirs(MODEL_DIR, exist_ok=True)


#call the home routes
app.register_blueprint(auth_bp)
app.register_blueprint(saveCopies_bp)
app.register_blueprint(loadDataset_bp)
app.register_blueprint(viewCopies_bp)
app.register_blueprint(datasets_bp)
app.register_blueprint(renamedatasets_bp)
app.register_blueprint(themeauth_bp)
app.register_blueprint(dataVisualize_bp)
app.register_blueprint(overview_bp)

#call the profile routes
app.register_blueprint(profile_details_bp)
# --------------------------------------------------
# HOME
# --------------------------------------------------
@app.route("/")
def myIndex():
  username = "Guest"

  if "user" in session:
     username = session["user"]["username"]

  return render_template(
        "dashboard.html",
        username=username
    )


@app.route("/home")
def home():

    username = "Guest"

    if "user" in session:
        username = session["user"]["username"]

    return render_template(
        "index.html",
        username=username
    )

@app.route("/login")
def login_page():

    return render_template("login.html")
    
@app.route("/register")
def register_page():

    return render_template("register.html")

@app.route("/verify", methods=["GET"])
def verify_page():
    return render_template("verify.html")
    
@app.route("/coming_soon", methods=["GET"])
def coming_page():
    return render_template("comingSoon.html")
    
@app.route("/profile", methods=["GET"])
def profile():
    return render_template("profile.html")
    
@app.route("/view_model")
def view_model_page():

    return render_template("view_model.html")
    
@app.route("/run_model_page")
def run_model_page():

    return render_template("run_model.html")
    
@app.route("/view_dataset")
def view_dataset_page():

    return render_template("view_dataset.html")
    
    
@app.route("/view_copy")
def view_copy_page():

    return render_template("view_copy.html")
    
@app.route("/settings", methods=["GET"])
def settings_page():
    return render_template("settings.html")

@app.route("/models")
def model_page():
    return render_template("models.html")

@app.route("/datasets")
def dataset_page():
    return render_template("datasets.html")
    
@app.route("/about")
def about_page():
    return render_template("about.html")


@app.route("/help")
def help_page():
    return render_template("help.html")
    
@app.route("/contact")
def contact_page():
    return render_template("contact.html")

@app.route("/account")
def account_page():
    return render_template("account.html")

    
@app.route("/forgot_password", methods=["GET"])
def forgot_password_page():
    return render_template("forgot_password.html")

@app.route("/reset_password", methods=["GET"])
def reset_password_page():
    return render_template("reset_password.html")
    


@app.route("/active_dataframe")
def active_dataframe():

    try:

        # -----------------------------------------
        # CLEAR MODEL CACHE WHEN DATASET IS LOADED
        # -----------------------------------------

        RUNNED_MODELS_CACHE.clear()


        # -----------------------------------------
        # LOAD FULL DATAFRAME
        # -----------------------------------------

        df, dataset_name = get_active_dataframe()


        # -----------------------------------------
        # TOTAL DATASET INFORMATION
        # -----------------------------------------

        total_rows = len(df)
        total_columns = len(df.columns)


        # -----------------------------------------
        # ONLY SEND ROWS NEEDED FOR DISPLAY
        # -----------------------------------------

        display_df = df.head(500).copy()


        # -----------------------------------------
        # HANDLE NULL / INVALID VALUES
        # -----------------------------------------

        display_df = display_df.replace(
            [np.nan, np.inf, -np.inf],
            None
        )


        # -----------------------------------------
        # RETURN DATA
        # -----------------------------------------

        return jsonify({

            "success": True,

            "name": dataset_name,

            "data": display_df.to_dict(
                orient="records"
            ),

            "columns": list(
                df.columns
            ),

            "total_rows": total_rows,

            "total_columns": total_columns

        })


    except Exception as e:

        # -----------------------------------------
        # NO ACTIVE DATASET
        # -----------------------------------------

        if str(e) == "No active dataset selected.":

            return jsonify({

                "success": False,

                "message":
                    "No dataset selected. "
                    "Upload or select a dataset "
                    "to get started.",

                "data": []

            }), 200


        # -----------------------------------------
        # OTHER ERRORS
        # -----------------------------------------

        print(
            "Active dataframe error:",
            e
        )


        return jsonify({

            "success": False,

            "message":
                "Unable to load the dataset.",

            "data": []

        }), 500
    
    
@app.route("/update_cell", methods=["POST"])
def update_cell():

    data = request.get_json()

    row = int(data["row"])
    column = data["column"]
    value = data["value"]

    df, _ = get_active_dataframe()   # <-- unpack here

    dtype = df[column].dtype

    try:
        if pd.api.types.is_integer_dtype(dtype):
            value = None if value == "" else int(value)

        elif pd.api.types.is_float_dtype(dtype):
            value = None if value == "" else float(value)

        elif pd.api.types.is_bool_dtype(dtype):
            value = value.lower() in ("true", "1", "yes")

        else:
            value = str(value)

    except ValueError:
        return jsonify({
            "success": False,
            "message": f"'{value}' is not a valid {dtype}"
        }), 400

    df.at[row, column] = value

    save_active_dataframe(df)

    return jsonify({"success": True})
    

# --------------------------------------------------
# UPLOAD DATASET
# --------------------------------------------------




@app.route("/upload", methods=["POST"])
def upload():

    # CLEAR THE MODEL CACHE WHEN A NEW DATASET IS LOADED
    RUNNED_MODELS_CACHE.clear()
    
    if "file" not in request.files:
        return jsonify({"error": "No file uploaded"}), 400

    file = request.files["file"]

    if file.filename == "":
        return jsonify({"error": "No file selected"}), 400

    ext = os.path.splitext(file.filename)[1].lower()

    if ext not in [".csv", ".json"]:
        return jsonify({"error": "Unsupported file type"}), 400

    # Create datasets folder if it doesn't exist
    os.makedirs(UPLOAD_FOLDER, exist_ok=True)

    # Generate unique filename
    stored_name = f"{uuid.uuid4()}{ext}"
    file_path = os.path.join(UPLOAD_FOLDER, stored_name)

    try:
        # Save uploaded file
        file.save(file_path)

        # Load into pandas
        if ext == ".csv":
            df = pd.read_csv(file_path ,encoding="utf-8",
    on_bad_lines="warn")
        else:
            df = pd.read_json(file_path ,encoding="utf-8",
    on_bad_lines="warn")

        # Logged-in user or guest
        user_id = None
        if "user" in session:
            user_id = session["user"]["id"]

        conn = get_db()
        cursor = conn.cursor()

        cursor.execute(
            """
            INSERT INTO datasets
            (
                user_id,
                original_name,
                stored_name,
                file_path,
                file_type,
                row_count,
                column_count,
                file_size
            )
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
            """,
            (
                user_id,
                file.filename,
                stored_name,
                file_path,
                ext.lstrip("."),
                len(df),
                len(df.columns),
                os.path.getsize(file_path)
            )
        )

        dataset_id = cursor.lastrowid
        
#session for active dataset

        session["active_dataset_id"] = dataset_id

        conn.commit()

        cursor.close()
        conn.close()

        return jsonify({
            "success": True,
            "dataset_id": dataset_id,
            "dataset_name": file.filename,
            "rows": len(df),
            "columns": list(df.columns)
        })

    except Exception as e:

        # Remove uploaded file if something failed
        if os.path.exists(file_path):
            os.remove(file_path)

        print(e)

        return jsonify({
            "success": False,
            "error": str(e)
        }), 500
        
#save model


@app.route("/save_model", methods=["POST"])
def save_model():
    data = request.get_json()
    model_type = data.get("model_type")
    target = data.get("target")

    if not model_type or not target:
        return jsonify({
            "success": False,
            "error": "Model type and target are required."
        }), 400

    cache_key = f"{model_type}_{target}"
    cached_package = RUNNED_MODELS_CACHE.get(cache_key)

    if not cached_package:
        return jsonify({
            "success": False, 
            "error": "No model found in memory. Please run the model first."
        }), 400

    # 1. Determine logged-in user (owner) or guest
    user_id = None
    if "user" in session:
        user_id = session["user"]["id"]

    # 2. Save file to disk using joblib (using uuid to prevent name collisions across models)
    filename = f"{model_type}_{target}_{uuid.uuid4().hex[:8]}.pkl"
    filepath = os.path.join(MODEL_DIR, filename)
    
    try:
        joblib.dump(cached_package, filepath)

        # 3. Extract metrics dynamically (works for regression, classification, etc.)
        # If your cached package has a "metrics" dict, store it as JSON string
        metrics_data = cached_package.get("metrics", {})
        
        # Fallback if metrics are stored flatly in the package
        if not metrics_data:
            metrics_data = {
                k: v for k, v in cached_package.items() 
                if k not in ["model_object", "model_type", "features", "target", "predictions"]
            }

        # 4. Insert universal details and owner info into the database
        conn = get_db()
        cursor = conn.cursor()

        cursor.execute(
            """
            INSERT INTO saved_models
            (
                user_id,
                model_type,
                target,
                features,
                file_path,
                metrics
            )
            VALUES (%s, %s, %s, %s, %s, %s)
            """,
            (
                user_id,
                model_type,
                target,
                json.dumps(cached_package.get("features", [])),
                filepath,
                json.dumps(metrics_data)
            )
        )

        model_db_id = cursor.lastrowid
        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({
            "success": True,
            "message": f"Model saved successfully as {filename} and logged to database!",
            "model_id": model_db_id
        })

    except Exception as e:
        # Clean up file if database insertion fails
        if os.path.exists(filepath):
            os.remove(filepath)
            
        print("Save model error:", str(e))
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

#run linear models
@app.route("/run_model", methods=["POST"])
def run_model():

    try:

        # -------------------------
        # GET DATA FROM FRONTEND
        # -------------------------

        data = request.get_json()

        model_type = data.get("model_type")

        features = data.get("features", [])

        target = data.get("target")

        test_size = data.get("test_size", 0.2)

        random_state = data.get("random_state", 42)


        # -------------------------
        # VALIDATION
        # -------------------------

        if not model_type:

            return jsonify({
                "success": False,
                "error": "No model type specified."
            }), 400


        if not features:

            return jsonify({
                "success": False,
                "error": "No features selected."
            }), 400


        if not target:

            return jsonify({
                "success": False,
                "error": "No target selected."
            }), 400


        if target in features:

            return jsonify({
                "success": False,
                "error":
                    "Target cannot also be a feature."
            }), 400


        # -------------------------
        # GET ACTIVE DATAFRAME
        # -------------------------

        active_data = get_active_dataframe()


        if active_data is None:

            return jsonify({
                "success": False,
                "error":
                    "No active dataset selected."
            }), 400


        # -------------------------
        # GET ACTUAL DATAFRAME
        # -------------------------

        if isinstance(active_data, tuple):

            df = active_data[0]

        else:

            df = active_data


        if not isinstance(df, pd.DataFrame):

            return jsonify({
                "success": False,
                "error":
                    "Active dataset is not a valid DataFrame."
            }), 400


        # -------------------------
        # CHECK COLUMNS
        # -------------------------

        required_columns = (
            features + [target]
        )


        missing_columns = [

            column

            for column in required_columns

            if column not in df.columns

        ]


        if missing_columns:

            return jsonify({

                "success": False,

                "error":
                    "Columns not found: "
                    + ", ".join(missing_columns)

            }), 400


        # -------------------------
        # GET ACTUAL COLUMN DATA
        # -------------------------

        X = df[features]

        y = df[target]


        # -------------------------
        # MODEL DISPATCHER
        # -------------------------

        if model_type == "linear_regression":

            result = linearRegression(

                df,

                features,

                target,

                test_size,

                random_state

            )


        elif model_type == "logistic_regression":

            result = logisticRegression(

                df,

                features,

                target,

                test_size,

                random_state

            )


        elif model_type == "decision_tree":

            result = decisionTree(

                df,

                features,

                target,

                test_size,

                random_state

            )


        elif model_type == "random_forest":

            result = randomForest(

                df,

                features,

                target,

                test_size,

                random_state

            )


        else:

            return jsonify({

                "success": False,

                "error":
                    f"Unsupported model type: {model_type}"

            }), 400


        # -------------------------
        # RETURN RESULT & SAVE MODEL
        # -------------------------

        if "model_object" in result:
            model_obj = result["model_object"]

            # 1. Save the model object to disk using joblib
            filename = f"{model_type}_{target}.joblib"
            file_path = os.path.join("saved_models", filename)
            os.makedirs("saved_models", exist_ok=True)
            joblib.dump(model_obj, file_path)

            # 2. Enter details into your Database
            # new_entry = ModelLog(
            #     model_name=result.get("model", model_type),
            #     target=target,
            #     features=str(features),
            #     r2_score=result.get("r2_score"),
            #     mse=result.get("mse"),
            #     file_path=file_path
            # )
            # db.session.add(new_entry)
            # db.session.commit()

            # 3. Cache the model object for fast runtime lookups/predictions
            cache_key = f"{model_type}_{target}"
            RUNNED_MODELS_CACHE[cache_key] = {
                "model_object": model_obj,
                "model_type": model_type,
                "features": features,
                "target": target,
                "file_path": file_path
            }

        # 4. Pop the model object so Flask JSON encoder doesn't crash
        result.pop("model_object", None)

        return jsonify({

            "success": True,

            **result

        })


    except Exception as e:

        print(
            "Model error:",
            str(e)
        )

        return jsonify({

            "success": False,

            "error": str(e)

        }), 500
# --------------------------------------------------
# GET DATASET
# --------------------------------------------------
@app.route("/dataset")
def dataset():

    try:

        df, _ = get_active_dataframe()

        # -----------------------------------------
        # ONLY SEND FIRST 500 ROWS
        # -----------------------------------------

        display_df = df.head(500).copy()


        # -----------------------------------------
        # HANDLE NULL VALUES
        # -----------------------------------------

        display_df = display_df.fillna("")


        # -----------------------------------------
        # RETURN DATA
        # -----------------------------------------

        return jsonify(
            display_df.to_dict(
                orient="records"
            )
        )


    except Exception as e:

        print(
            "Dataset error:",
            e
        )

        return jsonify({
            "error": "Unable to load dataset."
        }), 500


# --------------------------------------------------
# HEAD
# --------------------------------------------------
@app.route("/head")
def head():

    df, _ = get_active_dataframe()

    return jsonify(
        df.head().fillna("").to_dict(orient="records")
    )


# --------------------------------------------------
# TAIL
# --------------------------------------------------
@app.route("/tail")
def tail():

    df, _ = get_active_dataframe()

    return jsonify(
        df.tail().fillna("").to_dict(orient="records")
    )


# --------------------------------------------------
# SHAPE
# --------------------------------------------------
@app.route("/shape")
def shape():

    df, _ = get_active_dataframe()

    return jsonify({
        "rows": df.shape[0],
        "columns": df.shape[1]
    })


# --------------------------------------------------
# COLUMNS
# --------------------------------------------------
@app.route("/columns")
def columns():

    df, _ = get_active_dataframe()

    return jsonify(
        list(df.columns)
    )


# --------------------------------------------------
# DTYPES
# --------------------------------------------------
@app.route("/dtypes")
def dtypes():

    df, _ = get_active_dataframe()

    return jsonify(
        df.dtypes.astype(str).to_dict()
    )


# --------------------------------------------------
# INFO
# --------------------------------------------------
@app.route("/info")
def info():

    df, _ = get_active_dataframe()

    buffer = io.StringIO()

    df.info(buf=buffer)

    return jsonify({
        "info": buffer.getvalue()
    })


# --------------------------------------------------
# DESCRIBE
# --------------------------------------------------
@app.route("/describe")
def describe():

    df, _ = get_active_dataframe()

    return jsonify(
        df.describe(include="all")
        .fillna("")
        .T
        .reset_index()
        .rename(columns={"index": "Column"})
        .to_dict(orient="records")
    )

# --------------------------------------------------
# DUPLICATES
# --------------------------------------------------
@app.route("/duplicates")
def duplicates():

    df, _ = get_active_dataframe()

    duplicates = df[df.duplicated()]

    return jsonify(
        duplicates.fillna("").to_dict(orient="records")
    )


# --------------------------------------------------
# MISSING VALUES
# --------------------------------------------------
@app.route("/missing")
def missing():

    df, _ = get_active_dataframe()

    result = df.isnull().sum().to_dict()

    return jsonify(result)


# --------------------------------------------------
# REMOVE DUPLICATES
# --------------------------------------------------
@app.route("/remove_duplicates", methods=["POST"])
def remove_duplicates():

    df, _ = get_active_dataframe()

    before = len(df)

    df.drop_duplicates(inplace=True)

    save_active_dataframe(df)

    removed = before - len(df)

    return jsonify({
        "removed": removed,
        "rows": len(df)
    })


# --------------------------------------------------
# DROP MISSING ROWS
# --------------------------------------------------
@app.route("/drop_missing", methods=["POST"])
def drop_missing():

    df, _ = get_active_dataframe()

    before = len(df)

    df.dropna(inplace=True)

    save_active_dataframe(df)

    removed = before - len(df)

    return jsonify({
        "removed": removed,
        "rows": len(df)
    })


# --------------------------------------------------
# FILL MISSING
# --------------------------------------------------
@app.route("/fill_missing", methods=["POST"])
def fill_missing():

    df, _ = get_active_dataframe()

    method = request.json["method"]

    for col in df.columns:

        if df[col].dtype != object:

            if method == "mean":
                df[col] = df[col].fillna(df[col].mean())

            elif method == "median":
                df[col] = df[col].fillna(df[col].median())

        else:

            if method == "mode":

                mode = df[col].mode()

                if not mode.empty:
                    df[col] = df[col].fillna(mode.iloc[0])

    save_active_dataframe(df)

    return jsonify({
        "message": "Missing values filled"
    })

# --------------------------------------------------
# NORMALIZE COLUMN
# --------------------------------------------------
@app.route("/normalize", methods=["POST"])
def normalize():

    df, _ = get_active_dataframe()

    col = request.json["column"]

    df[col] = (
        df[col] - df[col].min()
    ) / (
        df[col].max() - df[col].min()
    )

    save_active_dataframe(df)

    return jsonify({
        "message": "Column normalized"
    })


# --------------------------------------------------
# ADD COLUMN
# --------------------------------------------------
#add column 
@app.route("/add_column", methods=["POST"])
def add_column():

    try:

        data = request.get_json()


        column = data.get("column")
        default = data.get("default", "")


        if not column:

            return jsonify({
                "success":False,
                "message":"Column name required"
            })


        df, _ = get_active_dataframe()


        # prevent duplicate columns

        if column in df.columns:

            return jsonify({
                "success":False,
                "message":"Column already exists"
            })



        # create column

        df[column] = default



        # save permanently

        save_active_dataframe(df)



        return jsonify({

            "success":True,
            "message":"Column added"

        })



    except Exception as e:


        print("ADD COLUMN ERROR:", e)


        return jsonify({

            "success":False,
            "message":str(e)

        }),500

# --------------------------------------------------
# DROP COLUMN
# --------------------------------------------------
#drop column
@app.route("/drop_column", methods=["POST"])
def drop_column():

    try:

        data = request.get_json()

        column = data.get("column")


        if not column:

            return jsonify({
                "success": False,
                "message": "Column name required"
            })


        df, _ = get_active_dataframe()


        if column not in df.columns:

            return jsonify({
                "success": False,
                "message": "Column does not exist"
            })


        df.drop(
            columns=[column],
            inplace=True
        )


        save_active_dataframe(df)


        return jsonify({

            "success": True,
            "message": f"{column} dropped"

        })


    except Exception as e:

        print("DROP COLUMN ERROR:", e)

        return jsonify({

            "success": False,
            "message": str(e)

        }),500


# --------------------------------------------------
# RENAME COLUMN
# --------------------------------------------------

@app.route("/rename_column", methods=["POST"])
def rename_column():

    try:

        data = request.get_json()


        old_name = data.get("old_name")
        new_name = data.get("new_name")


        if not old_name or not new_name:

            return jsonify({

                "success":False,
                "message":"Missing column names"

            })


        df, _ = get_active_dataframe()



        if old_name not in df.columns:

            return jsonify({

                "success":False,
                "message":"Old column not found"

            })



        if new_name in df.columns:

            return jsonify({

                "success":False,
                "message":"Column already exists"

            })



        df.rename(

            columns={
                old_name:new_name
            },

            inplace=True

        )


        save_active_dataframe(df)



        return jsonify({

            "success":True,
            "message":"Column renamed"

        })



    except Exception as e:


        print("RENAME COLUMN ERROR:",e)


        return jsonify({

            "success":False,
            "message":str(e)

        }),500
#add a Row
@app.route("/add_row", methods=["POST"])
def add_row():

    try:


        df, _ = get_active_dataframe()



        new_row = {

            col:""

            for col in df.columns

        }



        df.loc[len(df)] = new_row



        save_active_dataframe(df)



        return jsonify({

            "success":True,
            "message":"Row added"

        })



    except Exception as e:


        print("ADD ROW ERROR:",e)


        return jsonify({

            "success":False,
            "message":str(e)

        }),500
# --------------------------------------------------
# EXPORT CSV
# --------------------------------------------------
@app.route("/export")
def export():

    df, _ = get_active_dataframe()

    return df.to_csv(index=False)

# --------------------------------------------------
# VISUALIZATION
# --------------------------------------------------
@app.route("/visualize/<chart>")
def visualize(chart):

    df, _ = get_active_dataframe()

    return jsonify({
        "message": f"Generate {chart} chart here",
        "rows": len(df),
        "columns": list(df.columns)
    })


# --------------------------------------------------
# MACHINE LEARNING
# --------------------------------------------------
@app.route("/model/<model>", methods=["POST"])
def model(model):

    df, _ = get_active_dataframe()

    return jsonify({
        "message": f"Run {model} model here",
        "rows": len(df),
        "columns": list(df.columns)
    })


if __name__ == "__main__":
    app.run(debug=True)
