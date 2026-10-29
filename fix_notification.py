p = "E:/SMART - COACHES/Smart_coach_backend-main/Smart_coach_backend-main/src/utils/notificationService.js"
s = open(p).read()

old1 = """      }
    }
  }
}

/**
 * Save in-app"""
new1 = """      }
    } catch (err) {
      console.error("ERROR broadcastPushNotification:", err.message);
    }
  }
}

/**
 * Save in-app"""
s = s.replace(old1, new1, 1)

old2 = """      }
    }
  }
}

module.exports"""
new2 = """      }
    } catch (err) {
      console.error("ERROR saveInAppNotificationForAllUsers:", err.message);
    }
  }
}

module.exports"""
s = s.replace(old2, new2, 1)

open(p, "w").write(s)
print("done")
"""